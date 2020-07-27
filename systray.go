package main

import (
	// Standard Library
	"log"
	"os"

	// Third Party Libraries
	"github.com/getlantern/systray"
	"github.com/go-vgo/robotgo"
	"github.com/skratchdot/open-golang/open"

	// Nyrna Packages
	icon "github.com/Merrit/nyrna/icons"
)

func onReady() {
	systray.SetIcon(icon.Data)
	mRebind := systray.AddMenuItem("Change Hotkey", "Choose a new hotkey")
	mAbout := systray.AddMenuItem("About Nyrna " + VERSION, "Open changelog")
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
			if OS == "linux" {
				go RebindLinux()
			} else {
				robotgo.EventEnd()
				go rebindHotkeyWindows(HotkeyWindows)
			}
		case <-mAbout.ClickedCh:
			log.Println("Opening changelog in default browser.")
			err := open.Run(HOMEPAGE + "/releases/tag/v" + VERSION)
			if err != nil {
				log.Println("Error opening Nyrna changelog: ", err)
				// maybe also use Notify() to send a user-facing message
				// about the failure? Not sure what kind of error it returns..
			}
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
