package find_process_linux

import (
	// Standard Library
	"log"
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
