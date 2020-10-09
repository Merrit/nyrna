package find_process_linux

import (
	// Standard Library
	"log"
	"os/exec"
	"strconv"
	"strings"

	// Nyrna Packages
	nyrna "github.com/Merrit/nyrna"
)

func findWineProcess() (string, int32) {
	// Use ps to search for running *.exe processes
	log.Print("Searching for Wine process..")
	cmd := "ps aux | grep .exe$"
	psOutput, err := exec.Command("bash", "-c", cmd).Output()
	nyrna.Check(err)
	// Convert the ps output to a map
	psString := string(psOutput[:])
	// psSlice := strings.Fields(psString)
	psSlice := strings.Split(psString, "\n")
	log.Println(psSlice[0])
	psMap := make(map[string]string)
	for i := 0; i < len(psSlice); i += 2 {
		psMap[psSlice[i+1]] = psSlice[i]
	}
	// Print the results for debugging purposes
	for name, pid := range psMap {
		log.Println("Name:", name, "=>", "PID:", pid)
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
		nyrna.Check(err)
	}
	var processID int32 = int32(processIDint)
	log.Println("I think the real process is:", processName, "with PID:", processID)
	return processName, processID
}
