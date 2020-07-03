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
		log.Println(err)
	}
}

// NotifyResume sends a notification with the name of the resumed application.
func NotifyResume(name string) {
	message := fmt.Sprintf("%v was resumed.", name)
	err := beeep.Notify("Resumed", message, "icons/nyrna.png")
	if err != nil {
		log.Println(err)
	}
}
