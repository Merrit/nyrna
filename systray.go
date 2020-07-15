package main

import (
	// Standard Library
	"log"
	"os"

	// Third Party Libraries
	"github.com/getlantern/systray"

	// Nyrna Packages
	icon "github.com/Merrit/nyrna/icons"
)

func onReady() {
	systray.SetIcon(icon.Data)
	mRebind := systray.AddMenuItem("Change Hotkey", "Choose a new hotkey")
	systray.AddSeparator()
	mQuitOrig := systray.AddMenuItem("Quit", "Quit the whole app")
	go func() {
		<-mQuitOrig.ClickedCh
		log.Println("Quit pressed, exiting Nyrna.")
		systray.Quit()
		// The systray was closed, so exit Nyrna entirely
		// Maybe change this to call onExit() with further actions
		os.Exit(0)
	}()
	for {
		select {
		case <-mRebind.ClickedCh:
			go RebindLinux()
		}
	}
}

func onExit() {
	// clean up here
}

// StartTray will run the system tray concurrently
func StartTray() {
	systray.Run(onReady, onExit)
}
