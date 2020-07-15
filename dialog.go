package main

import (
	// Standard Library
	"log"
	"os/exec"
)

// RebindDialogLinux will prompt the user
// to input a new hotkey.
func RebindDialogLinux() (result string) {
	// Spawn a Zenity dialog box - Should we switch to 'yad'?
	cmd := exec.Command("zenity", "--info", "--width=400", "--height=200",
		"--title=Nyrna - Choose new hotkey",
		"--text=<span rise='10'><big><big>Press the new hotkey you would like to use, or Esc to cancel.</big></big></span>",
		"--ok-label=Cancel")
	err := cmd.Run()

	if err != nil {
		log.Println("Zenity - user pressed esc or completed keybind.")
		return "closed"
	}
	log.Println("Zenity - ", err, " - user clicked cancel or closed window")
	return "closed"
}
