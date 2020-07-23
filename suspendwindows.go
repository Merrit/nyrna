package main

import (
	"bytes"
	"log"
	"os"
	"os/exec"
	"strconv"

	"github.com/go-vgo/robotgo"
)

type windowsProcessObj struct {
	pid  int32
	name string
}

// WindowsProcess represents the process we find
var WindowsProcess *windowsProcessObj = &windowsProcessObj{}

func checkFileExists() (exists bool) {
	pslist := DataHome() + "pslist64.exe"
	pssuspend := DataHome() + "pssuspend64.exe"
	// Check if pslist exists
	var pslistExists bool
	if _, err := os.Stat(pslist); err == nil {
		pslistExists = true
	}
	// Check if pssuspend exists
	var pssuspendExists bool
	if _, err := os.Stat(pssuspend); err == nil {
		pssuspendExists = true
	}
	if pslistExists && pssuspendExists {
		return true
	}
	log.Println("Need tools, downloading..")
	return false
}

func getTools() {
	toolsExists := checkFileExists()
	if toolsExists == false {
		// Download pslist
		pslist := "( New-Item -Path " + DataHome() + "pslist64.exe" + " -Force )"
		cmd, err := exec.Command("cmd", "/C",
			"powershell.exe",
			"Invoke-WebRequest",
			"http://live.sysinternals.com/tools/pslist64.exe",
			"-OutFile",
			pslist).CombinedOutput()
		log.Printf("%s\n", cmd)
		if err != nil {
			log.Println("Error downloading pslist: ", err)
		}
		// Download pssuspend
		pssuspend := "( New-Item -Path " + DataHome() + "pssuspend64.exe" + " -Force )"
		cmd, err = exec.Command("cmd", "/C",
			"powershell.exe",
			"Invoke-WebRequest",
			"http://live.sysinternals.com/tools/pssuspend64.exe",
			"-OutFile",
			pssuspend).CombinedOutput()
		log.Printf("%s\n", cmd)
		if err != nil {
			log.Println("Error downloading pssuspend: ", err)
		}
	}
}

func getActiveWindowWindows() {
	// Get name
	activeWindowName := robotgo.GetTitle()
	log.Println("activeWindowName: ", activeWindowName)
	WindowsProcess.name = activeWindowName
	// Get PID
	activeWindowPID := robotgo.GetPID()
	log.Println("activeWindowPID: ", activeWindowPID)
	WindowsProcess.pid = activeWindowPID
}

// ToggleSuspendWindows will.. toggle suspend on Windows
func ToggleSuspendWindows() {
	getTools()
	// Check if a saved process file exists
	name, pid, err := LoadProcessFile()
	pidStr := strconv.Itoa(int(pid))
	switch {
	case err == nil:
		log.Println("Found saved process details - name:", name, "PID:", pid)
		cmd, err := exec.Command("cmd", "/C",
			PSLIST,
			"-accepteula",
			"-x",
			pidStr).CombinedOutput()
		log.Printf("%s\n", cmd)
		if err != nil {
			log.Println("Error running pslist: ", err)
		}
		// If a saved file exists, try to resume that process
		if bytes.Contains(cmd, []byte("Suspended")) {
			log.Println(name, "is stopped - resuming.")
			NotifyResume(name)
			cmd, err := exec.Command("cmd", "/C",
				PSSUSPEND,
				"-accepteula",
				"-r",
				pidStr).CombinedOutput()
			log.Printf("%s\n", cmd)
			if err != nil {
				log.Println("Error running pssuspend: ", err)
			}
			err = os.Remove(SavedProcessFile)
			Check(err)
		} else {
			err := os.Remove(SavedProcessFile)
			Check(err)
			log.Println(name, "is not suspended, removed invalid cache.")
		}
	// If no saved process file is found, suspend the active window
	case err != nil:
		log.Println("No saved process details found")
		getActiveWindowWindows()
		log.Println("Suspending", WindowsProcess.name)
		NotifySuspend(WindowsProcess.name)
		pidStr = strconv.Itoa(int(WindowsProcess.pid))
		cmd, err := exec.Command("cmd", "/C",
			PSSUSPEND,
			"-accepteula",
			pidStr).CombinedOutput()
		log.Printf("%s\n", cmd)
		if err != nil {
			log.Println("Error running pssuspend: ", err)
		}
		// Save suspended process details to file
		SaveProcessFile(WindowsProcess.name, WindowsProcess.pid)
	}
}
