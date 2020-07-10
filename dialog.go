package main

import (
	// Standard Library
	"log"
	"os/exec"
)

// RebindDialogLinux will prompt the user
// to input a new hotkey.
func RebindDialogLinux() {
	// Spawn a Zenity dialog box - Should we switch to 'yad'?
	cmd := exec.Command("zenity", "--info", "--width=400", "--height=200",
		"--title=Nyrna - Choose new hotkey",
		"--text=<span rise='10'><big><big>Press the new hotkey you would like to use, or Esc to cancel.</big></big></span>",
		"--ok-label=Cancel")
	err := cmd.Start()
	if err != nil {
		log.Println("Error creating Zenity dialog: ", err)
	}
	log.Printf("Spawning rebind window, press keys for new hotkey.")
	// err = cmd.Wait()
	// Start listening for new hotkey
	RebindLinux()
	// Check result
	if err != nil {
		log.Println("Rebind failed with error: ", err)
	} else {
		log.Println("Rebind finished successfully.") // TODO: New hotkey is $hotkey
	}
}
