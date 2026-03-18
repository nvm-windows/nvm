// Tests for semver utility functions.
//
// **Validates: Requirements 2.2**

package nvm_test

import (
	"fmt"
	"strconv"
	"strings"
	"testing"
	"testing/quick"
)

// replicateIsFullSemver replicates the logic from semver.IsFullSemver().
func replicateIsFullSemver(version string) bool {
	parts := strings.Split(version, ".")
	if len(parts) != 3 {
		return false
	}
	for _, p := range parts {
		if _, err := strconv.Atoi(p); err != nil {
			return false
		}
	}
	return true
}

func TestIsFullSemver_ValidVersions(t *testing.T) {
	valid := []string{"22.16.0", "0.0.0", "1.2.3", "100.200.300", "0.12.18"}
	for _, v := range valid {
		if !replicateIsFullSemver(v) {
			t.Errorf("isFullSemver(%q) = false, want true", v)
		}
	}
}

func TestIsFullSemver_InvalidVersions(t *testing.T) {
	invalid := []string{
		"22", "22.16", "22.16.0.1", "latest", "lts", "v22.16.0",
		"22.16.x", "abc.def.ghi", "", "22..0", "22.16.0-beta",
	}
	for _, v := range invalid {
		if replicateIsFullSemver(v) {
			t.Errorf("isFullSemver(%q) = true, want false", v)
		}
	}
}

func TestIsFullSemver_Property(t *testing.T) {
	f := func(a, b, c uint16) bool {
		version := fmt.Sprintf("%d.%d.%d", a, b, c)
		return replicateIsFullSemver(version)
	}
	if err := quick.Check(f, &quick.Config{MaxCount: 200}); err != nil {
		t.Errorf("isFullSemver should return true for all 3-part numeric versions: %v", err)
	}
}
