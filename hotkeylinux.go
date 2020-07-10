// https://github.com/BurntSushi/xgbutil/blob/master/_examples/simple-keybinding/main.go

package main

import (
	// Standard Library
	"log"
	"strings"

	// Third Party Libraries
	"github.com/BurntSushi/xgbutil"
	"github.com/BurntSushi/xgbutil/ewmh"
	"github.com/BurntSushi/xgbutil/keybind"
	"github.com/BurntSushi/xgbutil/xevent"
)

/* -------------------------------------------------------------------------- */
/*                                   Hotkey                                   */
/* -------------------------------------------------------------------------- */

// StartHotkeyLinux will listen for the configured hotkey globally,
// then call the function to toggle suspend.
func StartHotkeyLinux() {
	// Connect to the X server using the DISPLAY environment variable.
	X, err := xgbutil.NewConn()
	if err != nil {
		log.Fatal(err)
	}
	// Initialize the connection
	keybind.Initialize(X)
	// Callback function to listen for the Hotkey
	err = keybind.KeyReleaseFun(
		func(X *xgbutil.XUtil, e xevent.KeyReleaseEvent) {
			// Do things
			log.Printf("Pause key was pressed")
			// ToggleSuspend()
			// RebindLinux()
			// RebindDialog()
		}).Connect(X, X.RootWin(), "Pause", true)
	if err != nil {
		log.Fatal(err)
	}
	// Start the event loop to listen for the hotkey.
	// This will route events to the callback function,
	// which can then take appropriate actions.
	log.Println("Nyrna initialized, listening for pause key.")
	xevent.Main(X)
}

/* -------------------------------------------------------------------------- */
/*                                Rebind Hotkey                               */
/* -------------------------------------------------------------------------- */

// RebindLinux will listen for a new hotkey and save preference to config
func RebindLinux() {
	// Connect to the X server using the DISPLAY environment variable.
	/* 	X, err := xgbutil.NewConn()
	   	if err != nil {
	   		log.Fatal(err)
	   	} */
	/* -------------------------------------------------------------------------- */

	// Connect to the X server using the DISPLAY environment variable.
	X, err := xgbutil.NewConn()
	Check(err)
	// Get the Window ID of the active window
	windowID, err := ewmh.ActiveWindowGet(X)
	Check(err)
	log.Printf("Window ID: %d", windowID)
	// Get the name of the active window
	windowName, err := ewmh.WmNameGet(X, windowID)
	Check(err)
	log.Println("Window name: ", windowName)

	/* -------------------------------------------------------------------------- */
	// Initialize the connection
	keybind.Initialize(X)
	// Create a new window. We will listen for key presses and
	// translate them only when this window is in focus.
	/* 	win, err := xwindow.Generate(X)
	   	if err != nil {
	   		log.Fatalf("Could not generate a new window X id: %s", err)
	   	} */

	/* -------------------------- Define Rebind Window -------------------------- */

	/* 	win.Create(X.RootWin(), 0, 0, 500, 500, xproto.CwBackPixel, 0xffffffff)
	   	// Listen for Key{Press,Release} events.
	   	win.Listen(xproto.EventMaskKeyPress, xproto.EventMaskKeyRelease)
	   	// Map the window.
	   	win.Map()
	   	// Find the window ID
	   	wid := win.Id */

	/* ------------------------------ Rebind Logic ------------------------------ */

	// Callback function to listen for keys
	xevent.KeyPressFun(
		func(X *xgbutil.XUtil, e xevent.KeyPressEvent) {
			// Listen to modifier keys
			modStr := keybind.ModifierString(e.State)
			// Listen to regular keys
			keyStr := keybind.LookupString(X, e.State, e.Detail)
			// Remove NumLock modifier ("mod2") from string if found,
			// if present when setting the hotkey, it won't work.
			modStr = strings.Replace(modStr, "mod2-", "", -1)
			modStr = strings.Replace(modStr, "-mod2", "", -1)
			// Save new hotkey to preferences..
			switch {
			// Abort hotkey rebinding with Esc
			case keybind.KeyMatch(X, "Escape", e.State, e.Detail):
				log.Println("Escape detected. Hotkey not changed.")
				xevent.Quit(X)
				// win.Destroy()
			// Hotkey with modifiers
			case len(modStr) > 0 && modStr != "mod2":
				newHotkey := modStr + "+" + keyStr
				log.Println("New Hotkey (with modifiers): ", newHotkey)
			// Hotkey without modifiers
			default:
				newHotkey := keyStr
				log.Println("New Hotkey: ", newHotkey)
			}
		}).Connect(X, windowID)
	// Start the event loop to listen for rebind keys.
	// This will route events to the callback function.
	log.Println("Ready. Press the key(s) you wish to use for the hotkey.")
	xevent.Main(X)
}
