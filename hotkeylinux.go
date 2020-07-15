// https://github.com/BurntSushi/xgbutil/blob/master/_examples/simple-keybinding/main.go

package main

import (
	// Standard Library
	"log"
	"os/exec"
	"strings"

	// Third Party Libraries
	"github.com/BurntSushi/xgbutil"
	"github.com/BurntSushi/xgbutil/keybind"
	"github.com/BurntSushi/xgbutil/xevent"
)

type HotkeyLinux struct {
	keys string
}

var hotkey *HotkeyLinux = &HotkeyLinux{}
var xServer *xgbutil.XUtil = initializeHotkey()

func loadHotkey() {
	hotkey.keys = ConfigLoad() // Load default or saved hotkey
}

func updateHotkey(newHotkey string) {
	hotkey.keys = newHotkey
	ConfigWrite(newHotkey)
	// TODO: Currently when rebinding the hotkey, the previous
	// hotkey will continue to work until application restart.
	// Need to find out how to kill the old keybinding, as the
	// below wasn't working.
	/* 	err := keybind.KeyReleaseFun(
	   		func(X *xgbutil.XUtil, e xevent.KeyReleaseEvent) {
	   			// Use keybind.Detach to detach the root window
	   			// from all KeyPress *and* KeyRelease handlers.
	   			keybind.Detach(X, X.RootWin())

	   			log.Printf("Detached all Key{Press,Release}Events from the "+
	   				"root window (%d).", X.RootWin())
	   		}).Connect(xServer, xServer.RootWin(), newHotkey, true)
	   	if err != nil {
	   		log.Println("Error detaching hotkey: ", err)
	   	} */
	go StartHotkeyLinux()
}

func initializeHotkey() (xServer *xgbutil.XUtil) {
	// Connect to the X server using the DISPLAY environment variable.
	var err error
	xServer, err = xgbutil.NewConn()
	if err != nil {
		log.Fatal(err)
	}
	return xServer
}

// StartHotkeyLinux will listen for the configured hotkey globally.
func StartHotkeyLinux() {
	loadHotkey()
	X := xServer
	// Initialize the connection
	keybind.Initialize(X)
	// Callback function to listen for the Hotkey
	err := keybind.KeyReleaseFun(
		func(X *xgbutil.XUtil, e xevent.KeyReleaseEvent) {
			// Do things
			log.Println("Hotkey was pressed: ", hotkey.keys)
			ToggleSuspend()
		}).Connect(X, X.RootWin(), hotkey.keys, true)
	if err != nil {
		log.Println("Failed to start hotkey: ", err)
		NotifyHotkeyFailure(err)
	}
	// Start the event loop to listen for the hotkey.
	// This will route events to the callback function.
	log.Println("Nyrna initialized, listening for hotkey: ", hotkey.keys)
	xevent.Main(X)
}

// EndRebindDialogLinux - kill the window after we finish with it
func EndRebindDialogLinux(X *xgbutil.XUtil) {
	cmd := exec.Command("killall", "zenity")
	err := cmd.Run()
	if err != nil {
		log.Println("Killing Zenity dialog")
	}
	xevent.Quit(X)
	keybind.UngrabKeyboard(X)
}

// RebindLinux will listen for a new hotkey and save preference to config
func RebindLinux() {
	// Connect to the X server using the DISPLAY environment variable.
	X, err := xgbutil.NewConn()
	Check(err)
	// Initialize the connection
	keybind.Initialize(X)
	// Callback function to listen for keys
	xevent.KeyReleaseFun(
		func(X *xgbutil.XUtil, e xevent.KeyReleaseEvent) {
			// Listen to modifier keys
			modStr := keybind.ModifierString(e.State)
			// Listen to regular keys
			keyStr := keybind.LookupString(X, e.State, e.Detail)
			// Remove NumLock modifier ("mod2") from string if found,
			// if present when setting the hotkey it won't work.
			modStr = strings.Replace(modStr, "mod2-", "", -1)
			modStr = strings.Replace(modStr, "-mod2", "", -1)
			// This commented out code doesn't seem needed, reevaluate..
			/* if prefix control+Control Replace control+ ""

			niceModifiers = []string{
				"shift", "lock", "control", "mod1", "mod2", "mod3", "mod4", "mod5", "",
			} */
			switch {
			// Abort hotkey rebinding with Esc
			case keybind.KeyMatch(X, "Escape", e.State, e.Detail):
				log.Println("Escape detected. Hotkey not changed.")
				EndRebindDialogLinux(X)
			// Save new hotkey with modifiers
			case len(modStr) > 0 && modStr != "mod2":
				// Also seems unneeded..
				/* for _, niceModifier := range keybind.NiceModifiers {
					if modStr
				} */
				newHotkey := modStr + "-" + keyStr
				log.Println("New Hotkey (with modifiers): ", newHotkey)
				updateHotkey(newHotkey)
				EndRebindDialogLinux(X)
			// Save new hotkey without modifiers
			default:
				newHotkey := keyStr
				log.Println("New Hotkey: ", newHotkey)
				updateHotkey(newHotkey)
				EndRebindDialogLinux(X)
			}
		}).Connect(X, X.RootWin())
	// Show the rebind prompt
	go func() {
		dialogClosed := RebindDialogLinux()
		if dialogClosed == "closed" {
			EndRebindDialogLinux(X)
		}
	}()
	// Take over the entire keyboard to listen for the new hotkey.
	err = keybind.GrabKeyboard(X, X.RootWin())
	if err != nil {
		log.Println("Could not grab keyboard: ", err)
	} else {
		log.Println("WARNING: We are taking *complete* control of the keyboard. " +
			"The only way out is to press 'Escape' or to close the window with " +
			"the mouse.")
	}
	// Start the event loop to listen for rebind keys.
	// This will route events to the callback function.
	log.Println("Ready. Press the key(s) you wish to use for the hotkey.")
	xevent.Main(X)
}
