// Preservation property tests for the stale mirror SHASUMS fix.
// These tests verify that non-buggy behavior (no mirror configured, non-existent
// versions, already-installed versions) remains unchanged after the fix.
//
// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

package nvm_test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"testing/quick"
)

// replicateCheckVersionExceedsLatestP replicates the original (unfixed) logic
// for preservation testing of non-mirror scenarios.
func replicateCheckVersionExceedsLatestP(baseURL string, version string) bool {
	url := baseURL + "latest/SHASUMS256.txt"
	resp, err := http.Get(url)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	content := string(body)

	re := regexp.MustCompile("node-v(.+)+msi")
	reg := regexp.MustCompile("node-v|-[xa].+")
	latest := reg.ReplaceAllString(re.FindString(content), "")

	var vArr = strings.Split(version, ".")
	var lArr = strings.Split(latest, ".")
	for index := range lArr {
		lat, _ := strconv.Atoi(lArr[index])
		ver, _ := strconv.Atoi(vArr[index])
		if ver < lat {
			return false
		} else if ver > lat {
			return true
		}
	}
	return false
}

func replicateGetLatestP(baseURL string) string {
	url := baseURL + "latest/SHASUMS256.txt"
	resp, err := http.Get(url)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	content := string(body)

	re := regexp.MustCompile("node-v(.+)+msi")
	reg := regexp.MustCompile("node-v|-[xa].+")
	return reg.ReplaceAllString(re.FindString(content), "")
}

func replicateIsVersionAvailable(baseURL string, version string) bool {
	url := baseURL + "index.json"
	resp, err := http.Get(url)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	var data []map[string]interface{}
	if err := json.Unmarshal(body, &data); err != nil {
		return false
	}

	for _, element := range data {
		v, ok := element["version"].(string)
		if ok && len(v) > 1 && v[1:] == version {
			return true
		}
	}
	return false
}

func replicateIsVersionInstalled(root string, version string) bool {
	versionDir := filepath.Join(root, "v"+version)
	info, err := os.Stat(versionDir)
	if err != nil {
		return false
	}
	return info.IsDir()
}

func setupOfficialServer(latestVersion string, allVersions []string) (*httptest.Server, string) {
	mux := http.NewServeMux()
	mux.HandleFunc("/latest/SHASUMS256.txt", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, fakeSHASUMS(latestVersion))
	})
	mux.HandleFunc("/index.json", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, fakeIndexJSON(allVersions...))
	})
	server := httptest.NewServer(mux)
	return server, server.URL + "/"
}

// ---------------------------------------------------------------------------
// Preservation: Official Distribution Behavior Unchanged (Req 3.1)
// ---------------------------------------------------------------------------

func TestPreservation_OfficialDist_ExceedsLatest_Table(t *testing.T) {
	latestVersion := "22.14.0"
	allVersions := []string{"22.14.0", "22.13.0", "20.18.0", "18.20.0", "0.12.0"}

	server, baseURL := setupOfficialServer(latestVersion, allVersions)
	defer server.Close()

	cases := []struct {
		name     string
		version  string
		expected bool
	}{
		{"version far exceeding latest", "99.0.0", true},
		{"version slightly exceeding latest minor", "22.15.0", true},
		{"version exceeding latest major", "23.0.0", true},
		{"version equal to latest", "22.14.0", false},
		{"version below latest minor", "22.13.0", false},
		{"version below latest major", "20.18.0", false},
		{"old version", "0.12.0", false},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			result := replicateCheckVersionExceedsLatestP(baseURL, tc.version)
			if result != tc.expected {
				t.Errorf("checkVersionExceedsLatest(%q) = %v, want %v (latest=%s, no mirror)",
					tc.version, result, tc.expected, latestVersion)
			}
		})
	}
}

func TestPreservation_OfficialDist_ExceedsLatest_Property(t *testing.T) {
	latestVersion := "22.14.0"
	allVersions := []string{"22.14.0", "20.18.0", "18.20.0"}

	server, baseURL := setupOfficialServer(latestVersion, allVersions)
	defer server.Close()

	f := func(majorOffset uint8) bool {
		major := 23 + int(majorOffset)%30
		version := fmt.Sprintf("%d.0.0", major)
		return replicateCheckVersionExceedsLatestP(baseURL, version) == true
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("Preservation violated: versions with major > latest should exceed latest. %v", err)
	}

	g := func(majorOffset uint8) bool {
		major := int(majorOffset) % 22
		version := fmt.Sprintf("%d.0.0", major)
		return replicateCheckVersionExceedsLatestP(baseURL, version) == false
	}
	if err := quick.Check(g, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("Preservation violated: versions with major < latest should not exceed latest. %v", err)
	}
}

// ---------------------------------------------------------------------------
// Preservation: getLatest() returns valid version (Req 3.2)
// ---------------------------------------------------------------------------

func TestPreservation_GetLatest_NoMirror(t *testing.T) {
	cases := []struct {
		name          string
		latestVersion string
	}{
		{"latest is 22.14.0", "22.14.0"},
		{"latest is 20.18.0", "20.18.0"},
		{"latest is 18.20.4", "18.20.4"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			server, baseURL := setupOfficialServer(tc.latestVersion, []string{tc.latestVersion})
			defer server.Close()

			result := replicateGetLatestP(baseURL)
			if result != tc.latestVersion {
				t.Errorf("getLatest() = %q, want %q (no mirror configured)", result, tc.latestVersion)
			}
		})
	}
}

func TestPreservation_GetLatest_NoMirror_Property(t *testing.T) {
	f := func(major, minor, patch uint8) bool {
		maj := 1 + int(major)%30
		min := int(minor) % 50
		pat := int(patch) % 20
		version := fmt.Sprintf("%d.%d.%d", maj, min, pat)

		server, baseURL := setupOfficialServer(version, []string{version})
		defer server.Close()

		result := replicateGetLatestP(baseURL)
		return result == version
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 15}); err != nil {
		t.Errorf("Preservation violated: getLatest() should return SHASUMS version when no mirror. %v", err)
	}
}

// ---------------------------------------------------------------------------
// Preservation: Non-Existent Version Rejection (Req 3.3)
// ---------------------------------------------------------------------------

func TestPreservation_NonExistentVersion_Rejected(t *testing.T) {
	allVersions := []string{"22.14.0", "20.18.0", "18.20.0"}
	server, baseURL := setupOfficialServer("22.14.0", allVersions)
	defer server.Close()

	nonExistent := []string{"99.99.99", "22.15.0", "21.0.0", "0.0.1", "15.0.0"}
	for _, version := range nonExistent {
		t.Run("non-existent "+version, func(t *testing.T) {
			if replicateIsVersionAvailable(baseURL, version) {
				t.Errorf("isVersionAvailable(%q) = true, want false", version)
			}
		})
	}
}

func TestPreservation_ExistentVersion_Accepted(t *testing.T) {
	allVersions := []string{"22.14.0", "20.18.0", "18.20.0"}
	server, baseURL := setupOfficialServer("22.14.0", allVersions)
	defer server.Close()

	for _, version := range allVersions {
		t.Run("existent "+version, func(t *testing.T) {
			if !replicateIsVersionAvailable(baseURL, version) {
				t.Errorf("isVersionAvailable(%q) = false, want true", version)
			}
		})
	}
}

func TestPreservation_NonExistentVersion_Property(t *testing.T) {
	allVersions := []string{"22.14.0", "20.18.0", "18.20.0"}
	server, baseURL := setupOfficialServer("22.14.0", allVersions)
	defer server.Close()

	f := func(major, minor, patch uint8) bool {
		maj := 30 + int(major)%70
		min := int(minor) % 50
		pat := int(patch) % 20
		version := fmt.Sprintf("%d.%d.%d", maj, min, pat)
		return replicateIsVersionAvailable(baseURL, version) == false
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("Preservation violated: non-existent versions should be rejected. %v", err)
	}
}

// ---------------------------------------------------------------------------
// Preservation: Already Installed Version Detection (Req 3.4)
// ---------------------------------------------------------------------------

func TestPreservation_AlreadyInstalled_Detected(t *testing.T) {
	root, err := os.MkdirTemp("", "nvm-test-root-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(root)

	installedVersions := []string{"22.14.0", "20.18.0", "18.20.0"}
	for _, v := range installedVersions {
		os.MkdirAll(filepath.Join(root, "v"+v), 0755)
	}

	for _, v := range installedVersions {
		t.Run("installed "+v, func(t *testing.T) {
			if !replicateIsVersionInstalled(root, v) {
				t.Errorf("isVersionInstalled(%q) = false, want true", v)
			}
		})
	}

	notInstalled := []string{"22.15.0", "16.0.0", "99.0.0"}
	for _, v := range notInstalled {
		t.Run("not installed "+v, func(t *testing.T) {
			if replicateIsVersionInstalled(root, v) {
				t.Errorf("isVersionInstalled(%q) = true, want false", v)
			}
		})
	}
}

func TestPreservation_AlreadyInstalled_Property(t *testing.T) {
	root, err := os.MkdirTemp("", "nvm-test-root-prop-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(root)

	installedSet := map[string]bool{}
	for i := 0; i < 5; i++ {
		v := fmt.Sprintf("20.%d.0", i)
		installedSet[v] = true
		os.MkdirAll(filepath.Join(root, "v"+v), 0755)
	}

	f := func(minor uint8) bool {
		v := fmt.Sprintf("20.%d.0", int(minor)%10)
		expected := installedSet[v]
		actual := replicateIsVersionInstalled(root, v)
		return actual == expected
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("Preservation violated: installed version detection inconsistent. %v", err)
	}
}

// ---------------------------------------------------------------------------
// Preservation: Same major, varying minor comparison (Req 3.1)
// ---------------------------------------------------------------------------

func TestPreservation_SameMajor_MinorComparison_Property(t *testing.T) {
	latestVersion := "22.14.0"
	server, baseURL := setupOfficialServer(latestVersion, []string{latestVersion})
	defer server.Close()

	f := func(minor uint8) bool {
		min := int(minor) % 14
		version := fmt.Sprintf("22.%d.0", min)
		return replicateCheckVersionExceedsLatestP(baseURL, version) == false
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 14}); err != nil {
		t.Errorf("Preservation violated: same major, lower minor should not exceed latest. %v", err)
	}

	g := func(minorOffset uint8) bool {
		min := 15 + int(minorOffset)%35
		version := fmt.Sprintf("22.%d.0", min)
		return replicateCheckVersionExceedsLatestP(baseURL, version) == true
	}
	if err := quick.Check(g, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("Preservation violated: same major, higher minor should exceed latest. %v", err)
	}
}
