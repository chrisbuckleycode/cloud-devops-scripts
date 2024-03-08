// A basic validator/linter, checks yaml files in the current directory and sub-directories
//
// Instructions:
// go mod init example.com/yaml-check
// go mod tidy
// go run yaml_check.go

package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// checks if the YAML file has proper indentation.
func checkIndentation(filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNumber := 1
	for scanner.Scan() {
		line := scanner.Text()
		if !strings.HasPrefix(line, " ") && !strings.HasPrefix(line, "-") && !strings.HasPrefix(line, "#") {
			leadingSpaces := len(line) - len(strings.TrimLeft(line, " "))
			if leadingSpaces%2 != 0 {
				return fmt.Errorf("improper indentation in line %d: %s", lineNumber, line)
			}
		}
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("failed to read file: %v", err)
	}

	return nil // Proper indentation check passed
}

// checks if comments in the YAML file are correctly formatted.
func checkComments(filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNumber := 1
	commentPattern := regexp.MustCompile(`^\s*#.*$`)

	for scanner.Scan() {
		line := scanner.Text()
		if commentPattern.MatchString(line) {
			comment := strings.TrimSpace(line)
			if !strings.HasPrefix(comment, "# ") {
				return fmt.Errorf("incorrect comment format in line %d: %s", lineNumber, comment)
			}
		}
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("failed to read file: %v", err)
	}

	return nil // Comment format check passed
}

// performs the necessary checks on a YAML file.
func processFile(filePath string) {
	fmt.Printf("Processing file: %s\n", filePath)

	// Perform checks
	if err := checkIndentation(filePath); err != nil {
		fmt.Printf("Indentation check failed: %v\n", err)
	} else {
		fmt.Println("Indentation check passed")
	}

	if err := checkComments(filePath); err != nil {
		fmt.Printf("Comment format check failed: %v\n", err)
	} else {
		fmt.Println("Comment format check passed")
	}

	fmt.Println()
}

// recursively processes all YAML files in the given directory and its subdirectories.
func walkDir(dirPath string) {
	err := filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Check if the file is a YAML file
		if !info.IsDir() && (strings.HasSuffix(info.Name(), ".yaml") || strings.HasSuffix(info.Name(), ".yml")) {
			processFile(path)
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Failed to walk directory: %v\n", err)
		os.Exit(1)
	}
}

func main() {
	currentDir, err := os.Getwd()
	if err != nil {
		fmt.Printf("Failed to get current directory: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Checking YAML files in: %s\n\n", currentDir)
	walkDir(currentDir)
}
