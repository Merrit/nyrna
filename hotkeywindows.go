package main

import (
	// Standard Library
	"log"

	// Third Party Libraries
	"github.com/go-vgo/robotgo"
	hook "github.com/robotn/gohook"
)

type hotkeyWindowsObj struct {
	keys  uint16
	esc   uint16
	enter uint16
}

// HotkeyWindows is an object representing the hotkey on Windows.
var HotkeyWindows *hotkeyWindowsObj = &hotkeyWindowsObj{}

// StartHotkeyWindows handles setting up the
// global hotkey support for Windows.
func StartHotkeyWindows() {
	log.Println("Loading Windows Hotkey..")
	HotkeyWindows.keys = ConfigLoadWindows()
	// Set the default hotkey
	// var hotkey uint16
	if HotkeyWindows.keys == 0 {
		switch OS {
		case "linux":
			// Rawcode 65299 is Pause/Break key on Linux
			HotkeyWindows.keys = 65299
		case "windows":
			// Rawcode 19 is Pause/Break key on Windows
			HotkeyWindows.keys = 19
		}
	}
	// Start hotkey
	if HotkeyWindows.keys == 19 || HotkeyWindows.keys == 65299 {
		log.Println("Hotkey is Pause. Listening..")
	} else {
		log.Println("Hotkey is custom: ", HotkeyWindows.keys, "Listening..")
	}

	// This implementation of a hotkey could be made cross-platform
	// if you account for the fact that the Rawcode is different
	// depending if you are on Linux or Windows.
	evChan := robotgo.EventStart()
	for e := range evChan {
		// log.Println(e) // Only enabled for capturing key input tests
		// Rawcode ?: Pause/Break key on Linux
		// Rawcode 19: Pause/Break key on Windows
		if e.Kind == hook.KeyUp && e.Rawcode == HotkeyWindows.keys {
			log.Println("Pause key detected")
			ToggleSuspendWindows()
		}
	}
}

func rebindHotkeyWindows(hotkeyWindows *hotkeyWindowsObj) {
	// var esc uint16
	switch OS {
	case "linux":
		// Rawcode 65307 is Esc key on Linux
		hotkeyWindows.esc = 65307
		// Rawcode 65293 is Enter key on Linux
		hotkeyWindows.enter = 65293
	case "windows":
		// Rawcode 27 is Esc key on Windows
		hotkeyWindows.esc = 27
		// Rawcode 13 is Enter key on Windows
		hotkeyWindows.enter = 13
	}
	// Tell user how to rebind hotkey
	Notify("Press the desired new hotkey, or press Escape to cancel.")
	// Listen for key events (for rebind?)
	// Listen for Rawcode, then use Rawcode
	// for the new hotkey..
	log.Println("Press Esc to stop event gathering")
	// var newHotkeySlice []uint16
	evChan := robotgo.EventStart()
	for e := range evChan {
		if e.Rawcode == hotkeyWindows.esc {
			log.Println("Cancelling rebind")
			Notify("Rebind cancelled")
			robotgo.EventEnd()
			StartHotkeyWindows()
		} else if e.Kind == hook.KeyUp || e.Kind == hook.KeyDown {
			// hotkeyWindows.keys = e.Rawcode
			ConfigWriteWindows(e.Rawcode)
			Notify("New hotkey set")
			robotgo.EventEnd()
			StartHotkeyWindows()
		}
		// Follow is attempt at multi-key hotkey config..
		/* } else if e.Kind == hook.KeyUp && e.Rawcode == hotkeyWindows.enter {
				log.Println(newHotkeySlice)
			} else if e.Kind == hook.KeyUp {
				log.Println("You pressed ", e.Rawcode)
				newHotkeySlice = append(newHotkeySlice, e.Rawcode)
			}
		}
		if len(newHotkeySlice) > 0 && len(newHotkeySlice) < 5 {

		} */
	}
}
