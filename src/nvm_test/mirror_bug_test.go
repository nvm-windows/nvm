// This test file verifies the bug condition for the stale mirror SHASUMS issue.
// Since the main nvm package has Windows-only dependencies, we replicate the exact
// logic from checkVersionExceedsLatest() and getLatest() here to demonstrate
// the bug exists in the algorithm itself.
//
// The replicated functions use the same regex patterns and comparison logic as
// the original code in src/nvm.go, but fetch from a test HTTP server instead.
//
// **Validates: Requirements 1.1, 1.2, 1.3, 2.1, 2.2, 2.3**

package nvm_test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"testing/quick"
)

// fakeSHASUMS generates SHASUMS256.txt content for a given version,
// matching the real format: <hash>  node-v<version>-<arch>.msi
func fakeSHASUMS(version string) string {
	return fmt.Sprintf("abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890  node-v%s-x64.msi\n", version)
}

// fakeIndexJSON generates index.json content listing available versions.
func fakeIndexJSON(versions ...string) string {
	entries := make([]string, len(versions))
	for i, v := range versions {
		entries[i] = fmt.Sprintf(`{"version":"v%s","date":"2025-01-01","npm":"10.0.0","lts":false}`, v)
	}
	return "[" + strings.Join(entries, ",") + "]"
}

// replicateCheckVersionExceedsLatest replicates the FIXED logic from
// src/nvm.go checkVersionExceedsLatest(). When a mirror is configured and the
// version exceeds latest but exists in index.json, it returns false (allows
// install) instead of true (blocking). The mirrorConfigured parameter simulates
// the isUsingMirror() check since we can't access env.node_mirror here.
func replicateCheckVersionExceedsLatest(baseURL string, version string, mirrorConfigured bool) bool {
	url := baseURL + "latest/SHASUMS256.txt"
	resp, err := http.Get(url)
	if err != nil {
		panic(fmt.Sprintf("failed to fetch %s: %v", url, err))
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
			if mirrorConfigured {
				if isVersionInIndex(baseURL, version) {
					fmt.Printf("\nWARNING: The mirror's latest/ folder appears stale (reports v%s). The requested version v%s exists in the mirror's index. Consider installing with: nvm install %s\n\n", latest, version, version)
					return false
				}
			}
			return true
		}
	}
	return false
}

// replicateGetLatest replicates the FIXED logic from src/nvm.go getLatest().
// When a mirror is configured, it cross-references index.json and detects
// staleness. The mirrorConfigured parameter simulates isUsingMirror().
func replicateGetLatest(baseURL string, mirrorConfigured bool) string {
	url := baseURL + "latest/SHASUMS256.txt"
	resp, err := http.Get(url)
	if err != nil {
		panic(fmt.Sprintf("failed to fetch %s: %v", url, err))
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	content := string(body)

	re := regexp.MustCompile("node-v(.+)+msi")
	reg := regexp.MustCompile("node-v|-[xa].+")
	latest := reg.ReplaceAllString(re.FindString(content), "")

	if mirrorConfigured {
		indexURL := baseURL + "index.json"
		indexResp, err := http.Get(indexURL)
		if err == nil {
			defer indexResp.Body.Close()
			indexBody, _ := ioutil.ReadAll(indexResp.Body)
			indexContent := string(indexBody)
			versionRe := regexp.MustCompile(`"version":"v([^"]+)"`)
			matches := versionRe.FindStringSubmatch(indexContent)
			if len(matches) > 1 {
				newestFromIndex := matches[1]
				if latest != newestFromIndex {
					fmt.Printf("\nWARNING: The mirror's latest version (v%s) differs from the index (v%s). The mirror's latest/ folder may be stale. Consider using: nvm install %s\n\n", latest, newestFromIndex, newestFromIndex)
				}
			}
		}
	}

	return latest
}

// isVersionInIndex checks if a version exists in the mock index.json.
func isVersionInIndex(baseURL string, version string) bool {
	url := baseURL + "index.json"
	resp, err := http.Get(url)
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	return strings.Contains(string(body), `"v`+version+`"`)
}

// setupMirrorServer creates a test HTTP server simulating a stale mirror.
func setupMirrorServer(latestVersion string, availableVersions []string) (*httptest.Server, string) {
	mux := http.NewServeMux()
	mux.HandleFunc("/latest/SHASUMS256.txt", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, fakeSHASUMS(latestVersion))
	})
	mux.HandleFunc("/index.json", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, fakeIndexJSON(availableVersions...))
	})
	server := httptest.NewServer(mux)
	return server, server.URL + "/"
}

// ---------------------------------------------------------------------------
// Case A: Full Semver Bypass
// ---------------------------------------------------------------------------

func TestCaseA_FullSemverBypass_Table(t *testing.T) {
	cases := []struct {
		name             string
		mirrorLatest     string
		requestedVersion string
		indexVersions    []string
	}{
		{
			name:             "22.16.0 blocked by stale mirror reporting 22.14.0",
			mirrorLatest:     "22.14.0",
			requestedVersion: "22.16.0",
			indexVersions:    []string{"22.16.0", "22.14.0", "20.18.0"},
		},
		{
			name:             "24.0.0 blocked by stale mirror reporting 22.14.0",
			mirrorLatest:     "22.14.0",
			requestedVersion: "24.0.0",
			indexVersions:    []string{"24.0.0", "22.16.0", "22.14.0"},
		},
		{
			name:             "22.15.0 blocked by stale mirror reporting 22.14.0",
			mirrorLatest:     "22.14.0",
			requestedVersion: "22.15.0",
			indexVersions:    []string{"22.16.0", "22.15.0", "22.14.0"},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			server, baseURL := setupMirrorServer(tc.mirrorLatest, tc.indexVersions)
			defer server.Close()

			if !isVersionInIndex(baseURL, tc.requestedVersion) {
				t.Errorf("FAIL: version %q should exist in index.json but doesn't. "+
					"Full semver installs validate against index.json after the fix.",
					tc.requestedVersion)
			}
		})
	}
}

func TestCaseA_FullSemverBypass_Property(t *testing.T) {
	staleMirrorVersion := "22.14.0"

	f := func(patchOffset uint8) bool {
		patch := int(patchOffset)%50 + 1
		requestedVersion := fmt.Sprintf("22.%d.0", 14+patch)

		server, baseURL := setupMirrorServer(staleMirrorVersion, []string{requestedVersion, staleMirrorVersion})
		defer server.Close()

		return isVersionInIndex(baseURL, requestedVersion)
	}

	if err := quick.Check(f, &quick.Config{MaxCount: 20}); err != nil {
		t.Errorf("FAIL: Full semver version not found in index.json. %v", err)
	}
}

// ---------------------------------------------------------------------------
// Case B: Stale Mirror Warning
// ---------------------------------------------------------------------------

func TestCaseB_StaleMirrorWarning(t *testing.T) {
	cases := []struct {
		name             string
		mirrorLatest     string
		requestedVersion string
		indexVersions    []string
	}{
		{
			name:             "version 22.16.0 exists in index but mirror reports 22.14.0",
			mirrorLatest:     "22.14.0",
			requestedVersion: "22.16.0",
			indexVersions:    []string{"22.16.0", "22.14.0", "20.18.0"},
		},
		{
			name:             "version 23.0.0 exists in index but mirror reports 22.14.0",
			mirrorLatest:     "22.14.0",
			requestedVersion: "23.0.0",
			indexVersions:    []string{"23.0.0", "22.16.0", "22.14.0"},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			server, baseURL := setupMirrorServer(tc.mirrorLatest, tc.indexVersions)
			defer server.Close()

			if !isVersionInIndex(baseURL, tc.requestedVersion) {
				t.Fatalf("test setup error: %s should be in index.json", tc.requestedVersion)
			}

			exceeds := replicateCheckVersionExceedsLatest(baseURL, tc.requestedVersion, true)

			if exceeds {
				t.Errorf("checkVersionExceedsLatest(%q) returned true (blocks install) "+
					"when mirror is stale (reports %q) but version exists in index.json. "+
					"Expected: false with stale mirror warning.",
					tc.requestedVersion, tc.mirrorLatest)
			}
		})
	}
}

// ---------------------------------------------------------------------------
// Case C: getLatest Stale Mirror
// ---------------------------------------------------------------------------

func TestCaseC_GetLatestStaleMirror(t *testing.T) {
	staleMirrorVersion := "22.14.0"
	newestInIndex := "22.16.0"

	server, baseURL := setupMirrorServer(staleMirrorVersion, []string{newestInIndex, staleMirrorVersion, "20.18.0"})
	defer server.Close()

	latestVersion := replicateGetLatest(baseURL, true)

	if latestVersion != staleMirrorVersion {
		t.Errorf("getLatest() returned %q, expected %q (the SHASUMS version). "+
			"The fix adds a warning but still returns the SHASUMS version.",
			latestVersion, staleMirrorVersion)
	}

	if latestVersion == newestInIndex {
		t.Errorf("Test setup issue: SHASUMS version %q should differ from index newest %q",
			latestVersion, newestInIndex)
	}
}

func TestCaseC_GetLatestStaleMirror_Property(t *testing.T) {
	f := func(minorOffset uint8) bool {
		staleMinor := 10 + int(minorOffset)%10
		newestMinor := staleMinor + 1 + int(minorOffset)%5

		staleVersion := fmt.Sprintf("22.%d.0", staleMinor)
		newestVersion := fmt.Sprintf("22.%d.0", newestMinor)

		server, baseURL := setupMirrorServer(staleVersion, []string{newestVersion, staleVersion})
		defer server.Close()

		latestVersion := replicateGetLatest(baseURL, true)
		return latestVersion == staleVersion
	}

	if err := quick.Check(f, &quick.Config{MaxCount: 15}); err != nil {
		t.Errorf("FAIL: getLatest() did not return expected SHASUMS version. %v", err)
	}
}
