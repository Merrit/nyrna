package main

import (
	// Standard Library
	"fmt"
	"log"

	// Third Party Libraries
	"github.com/gen2brain/beeep"
)

// NotifySuspend sends a notification with the name of the suspended application.
func NotifySuspend(name string) {
	message := fmt.Sprintf("%v was suspended.", name)
	err := beeep.Notify("Suspended", message, "icons/nyrna.png")
	if err != nil {
		log.Println("NotifySuspend error: ", err)
	}
}

// NotifyResume sends a notification with the name of the resumed application.
func NotifyResume(name string) {
	message := fmt.Sprintf("%v was resumed.", name)
	err := beeep.Notify("Resumed", message, "icons/nyrna.png")
	if err != nil {
		log.Println("NotifyResume error: ", err)
	}
}

// NotifyHotkeyFailure sends a notification if we fail to activate the hotkey
func NotifyHotkeyFailure(hotkeyErr error) {
	message := fmt.Sprintf("%v", hotkeyErr)
	err := beeep.Notify("Issue", message, "icons/nyrna.png")
	if err != nil {
		log.Println("NotifyHotkeyFailure error: ", err)
	}
}

// Notify sends a notification instructing how to rebind hotkey
func Notify(msg string) {
	message := fmt.Sprintf("%v", msg)
	err := beeep.Notify("Info", message, "icons/nyrna.png")
	if err != nil {
		log.Println("Notify failure error: ", err)
	}
}
