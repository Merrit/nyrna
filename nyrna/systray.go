package main

import (
	// Standard Library
	"os"

	// Third Party Libraries
	"github.com/getlantern/systray"

	// Nyrna Packages
	icon "github.com/Merrit/nyrna/tree/master/nyrna/icons"
)

func onReady() {
	systray.SetIcon(icon.Data)
	mQuitOrig := systray.AddMenuItem("Quit", "Quit the whole app")
	go func() {
		<-mQuitOrig.ClickedCh
		systray.Quit()
		// The systray was closed, so exit Nyrna entirely
		// Maybe change this to call onExit() with further actions
		os.Exit(0)
	}()
}

func onExit() {
	// clean up here
}

// StartTray will run the system tray concurrently
func StartTray() {
	systray.Run(onReady, onExit)
}
