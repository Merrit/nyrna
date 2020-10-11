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
	// Use ps to search for running *.exe processes
	log.Print("Searching for Wine process..")
	cmd := "ps aux | grep .exe$"
	psOutput, err := exec.Command("bash", "-c", cmd).Output()
	Check(err)
	// Convert the output to a string so we can search and manipulate.
	psString := string(psOutput[:])
	// Each line of the output is for a single process, so seperate them into
	// a slice, one for each process found.
	var rawProcesses []string = strings.Split(psString, "\n")
	// Create a map of the found processes in the form of name:PID.
	psMap := make(map[string]string)
	for _, process := range rawProcesses {
		if process != "" {
			// Split the string by white space.
			// 0th entry should be the user, which we don't care about.
			// 1st entry should be the PID.
			var parts []string = strings.Fields(process)
			var PID string = parts[1]
			// log.Printf("PID: %v", PID)
			findName := strings.Split(process, "\\")
			var processName string = findName[len(findName)-1]
			// log.Printf("processName: %v", processName)
			psMap[processName] = PID
		}
	}
	// Print the results for debugging purposes
	for name, pid := range psMap {
		log.Println("\n", "Name:", name, "\n", "PID:", pid, "\n ")
	}
	// Remove the .exe processes belonging to Wine
	for name := range psMap {
		switch name {
		case "services.exe":
			delete(psMap, name)
			fallthrough
		case "explorer.exe":
			delete(psMap, name)
			fallthrough
		case "winedevice.exe":
			delete(psMap, name)
			fallthrough
		case "plugplay.exe":
			delete(psMap, name)
		}
	}
	if len(psMap) != 1 {
		log.Println("Multiple remaining processes:", psMap)
		log.Println("Not able to find real wine process! Please report this issue.")
	}
	// Extract name and pid from the map
	var processName string
	var processIDint int
	for name, pid := range psMap {
		processName = name
		processIDint, err = strconv.Atoi(pid)
		Check(err)
	}
	var processID int32 = int32(processIDint)
	log.Println("I think the real process is:", processName, "with PID:", processID)
	return processName, processID
}
