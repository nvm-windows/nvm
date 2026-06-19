package utility

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

// Rename moves old to new.
//
// It first attempts a cheap filesystem rename, which only works when the source
// and destination live on the same volume. That rename can still fail on
// Windows when a file in the source tree is briefly locked right after an unzip
// (e.g. antivirus scanning a freshly-extracted 100MB+ node.exe), so it is
// retried with a short backoff. If the rename ultimately fails — whether because
// the paths are on different volumes or because the directory entry simply
// cannot be moved — it falls back to a recursive copy + delete, which opens each
// file individually instead of relying on a single atomic directory rename.
//
// This makes the temp->install-root move reliable. Previously a same-volume
// os.Rename failure was returned verbatim and aborted the install, leaving the
// fully-extracted files stranded in the temp directory while nvm reported
// success — the root cause of issue #1357.
func Rename(old, new string) error {
	sameVolume := filepath.VolumeName(old) == filepath.VolumeName(new)

	// Fast path: a real rename is only possible within a single volume.
	if sameVolume {
		var err error
		for _, backoff := range []time.Duration{0, 1, 2, 4} {
			if backoff > 0 {
				time.Sleep(backoff * time.Second)
			}
			if err = os.Rename(old, new); err == nil {
				return nil
			}
		}
		// The rename kept failing even though both paths are on the same
		// volume. Fall through to copy + remove rather than aborting.
	}

	return copyThenRemove(old, new)
}

// copyThenRemove recursively copies old to new and then deletes old. It is used
// both for cross-volume moves and as a fallback when an in-volume rename fails.
func copyThenRemove(old, new string) error {
	// Get file or directory info
	info, err := os.Stat(old)
	if err != nil {
		return fmt.Errorf("failed to stat source: %w", err)
	}

	// If old is a directory, copy recursively
	if info.IsDir() {
		err = copyDir(old, new)
		if err != nil {
			return fmt.Errorf("failed to copy directory: %w", err)
		}
	} else {
		// Otherwise, copy a single file
		err = copyFile(old, new)
		if err != nil {
			return fmt.Errorf("failed to copy file: %w", err)
		}
	}

	// Remove the original source
	err = os.RemoveAll(old)
	if err != nil {
		return fmt.Errorf("failed to remove source: %w", err)
	}

	return nil
}

// copyFile copies a single file from source (old) to destination (new).
func copyFile(old, new string) error {
	srcFile, err := os.Open(old)
	if err != nil {
		return fmt.Errorf("failed to open source file: %w", err)
	}
	defer srcFile.Close()

	// Ensure destination directory exists
	destDir := filepath.Dir(new)
	err = os.MkdirAll(destDir, os.ModePerm)
	if err != nil {
		return fmt.Errorf("failed to create destination directory: %w", err)
	}

	destFile, err := os.Create(new)
	if err != nil {
		return fmt.Errorf("failed to create destination file: %w", err)
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, srcFile)
	if err != nil {
		return fmt.Errorf("failed to copy data: %w", err)
	}

	// Copy file permissions
	info, err := srcFile.Stat()
	if err != nil {
		return fmt.Errorf("failed to get source file info: %w", err)
	}
	err = os.Chmod(new, info.Mode())
	if err != nil {
		return fmt.Errorf("failed to set permissions on destination file: %w", err)
	}

	return nil
}

// copyDir recursively copies a directory from old path to new path.
func copyDir(old, new string) error {
	entries, err := os.ReadDir(old)
	if err != nil {
		return fmt.Errorf("failed to read source directory: %w", err)
	}

	// Ensure destination directory exists
	err = os.MkdirAll(new, os.ModePerm)
	if err != nil {
		return fmt.Errorf("failed to create destination directory: %w", err)
	}

	for _, entry := range entries {
		srcPath := filepath.Join(old, entry.Name())
		destPath := filepath.Join(new, entry.Name())

		if entry.IsDir() {
			err = copyDir(srcPath, destPath)
			if err != nil {
				return fmt.Errorf("failed to copy subdirectory: %w", err)
			}
		} else {
			err = copyFile(srcPath, destPath)
			if err != nil {
				return fmt.Errorf("failed to copy file: %w", err)
			}
		}
	}

	return nil
}
