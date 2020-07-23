package main

import (
	// Standard Library
	"log"
	"os"

	// Third Party Libraries
	"github.com/shirou/gopsutil/process"
)

// FindProcess is the beginning of the tree to
// find the process for the active window.
func findProcess() (string, int32) {
	var name string
	var pid int32
	switch OS {
	case "linux":
		name, pid = GetActiveWindowLinux()
	case "windows":
		// gopsutil doesn't support suspend / resume on Windows..
		log.Println("Windows is not yet supported.")
	}
	return name, pid
}

// ToggleSuspend will first check for a saved process from a
// previous suspend, if one is found it will resume that.
// Otherwise it will call the function to find the process
// information for the active window, then suspend that process.
func ToggleSuspend() {
	// Check if a saved process file exists
	name, pid, err := LoadProcessFile()
	switch {
	case err == nil:
		log.Println("Found saved process details - name:", name, "PID:", pid)
		process, err := process.NewProcess(pid)
		Check(err)
		status, err := process.Status()
		Check(err)
		// If a saved file exists, try to resume that process
		if status == "T" {
			log.Println(name, "is stopped - resuming.")
			NotifyResume(name)
			process.Resume()
			err := os.Remove(SavedProcessFile)
			Check(err)
		} else {
			err := os.Remove(SavedProcessFile)
			Check(err)
			log.Println(name, "is not suspended, removed invalid cache.")
		}
	// If no saved process file is found, suspend the active window
	case err != nil:
		log.Println("No saved process details found")
		name, pid := findProcess()
		process, err := process.NewProcess(pid)
		Check(err)
		status, err := process.Status()
		Check(err)
		if status == "T" {
			status = "Suspended"
		} else {
			status = "Running"
		}
		log.Println("Checking process - name:", name, "PID:", pid, "status:", status)
		switch status {
		case "Running":
			log.Println("Suspending", name)
			NotifySuspend(name)
			process.Suspend()
		case "Suspended":
			log.Println("Resuming", name)
			NotifyResume(name)
			process.Resume()
		}
		// Save suspended process details to file
		SaveProcessFile(name, pid)
	}
}
