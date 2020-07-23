package main

import (
	// Standard Library
	"log"
	"os/exec"
	"strconv"
	"strings"

	// Third Party Libraries
	"github.com/BurntSushi/xgbutil"
	"github.com/BurntSushi/xgbutil/ewmh"
)

// GetActiveWindowLinux will find the process information for the
// active window, and if a Wine emulated desktop is detected it will
// call findWineProcess to discover the real process information.
func GetActiveWindowLinux() (string, int32) {
	// TODO: Send notification if there is an error with these
	// Connect to the X server using the DISPLAY environment variable.
	X, err := xgbutil.NewConn()
	if err != nil {
		log.Println("Error connecting to X Server: ", err)
	}
	// Get the Window ID of the active window
	windowID, err := ewmh.ActiveWindowGet(X)
	if err != nil {
		log.Println("Error getting ID of active window: ", err)
	}
	log.Printf("Window ID: %d", windowID)
	// Get the PID of the active window
	pid, err := ewmh.WmPidGet(X, windowID)
	if err != nil {
		log.Println("Error getting PID of active window: ", err)
	}
	log.Printf("PID: %d", pid)
	processID := int32(pid)
	// Get the name of the active window
	windowName, err := ewmh.WmNameGet(X, windowID)
	if err != nil {
		log.Println("Error getting name of active window: ", err)
	}
	log.Printf("Window name: %s", windowName)
	// Check if the window is a Wine virtual desktop
	if strings.Contains(windowName, "explorer.exe") == false &&
		strings.Contains(windowName, "WineDesktop") == false &&
		strings.Contains(windowName, "Wine") == false {
		log.Print("Not a Wine process")
		return windowName, processID
	}
	log.Print("Found a Wine emulated desktop")
	return findWineProcess()
}

func findWineProcess() (string, int32) {
	// Use pgrep to search for running *.exe processes
	log.Print("Searching for Wine process..")
	pgrepOut, err := exec.Command("pgrep", ".exe$", "-l").Output()
	Check(err)
	// Convert the pgrep output to a map
	pgrepString := string(pgrepOut[:])
	pgrepSlice := strings.Fields(pgrepString)
	pgrepMap := make(map[string]string)
	for i := 0; i < len(pgrepSlice); i += 2 {
		pgrepMap[pgrepSlice[i+1]] = pgrepSlice[i]
	}
	// Print the results for debugging purposes
	for name, pid := range pgrepMap {
		log.Println("Name:", name, "=>", "PID:", pid)
	}
	// Remove the .exe processes belonging to Wine
	for name := range pgrepMap {
		switch name {
		case "services.exe":
			delete(pgrepMap, name)
			fallthrough
		case "explorer.exe":
			delete(pgrepMap, name)
			fallthrough
		case "winedevice.exe":
			delete(pgrepMap, name)
			fallthrough
		case "plugplay.exe":
			delete(pgrepMap, name)
		}
	}
	if len(pgrepMap) != 1 {
		log.Println("Multiple remaining processes:", pgrepMap)
		log.Fatal("Not able to find real wine process! Please report this issue.")
	}
	// Extract name and pid from the map
	var processName string
	var processIDint int
	for name, pid := range pgrepMap {
		processName = name
		processIDint, err = strconv.Atoi(pid)
		Check(err)
	}
	var processID int32 = int32(processIDint)
	log.Println("I think the real process is:", processName, "with PID:", processID)
	return processName, processID
}
