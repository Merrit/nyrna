package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

// LoadProcessFile checks for a saved process file,
// and if one is found returns the saved values(name and pid).
func LoadProcessFile() (string, int32, error) {
	path := SavedProcessFile
	file, err := os.Open(path)
	if err != nil {
		return "", 0, err
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	var name string = lines[0]
	pidString, err := strconv.Atoi(lines[1])
	var pid int32 = int32(pidString)
	return name, pid, scanner.Err()
}

// SaveProcessFile saves the name and pid values to a file on separate
// lines so that when the program is called again it can resume
// a process even when its window can't be focused.
func SaveProcessFile(name string, pid int32) error {
	path := SavedProcessFile
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	w := bufio.NewWriter(file)

	fmt.Fprintln(w, name)
	fmt.Fprintln(w, pid)
	return w.Flush()
}
