// https://github.com/BurntSushi/xgbutil/blob/master/_examples/simple-keybinding/main.go

package main

import (
	// Standard Library

	"log"
	"strings"

	// Third Party Libraries
	"github.com/BurntSushi/xgb/xproto"

	"github.com/BurntSushi/xgbutil"
	"github.com/BurntSushi/xgbutil/keybind"
	"github.com/BurntSushi/xgbutil/xevent"
	"github.com/BurntSushi/xgbutil/xwindow"
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
			RebindLinux()
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
	X, err := xgbutil.NewConn()
	if err != nil {
		log.Fatal(err)
	}
	// Initialize the connection
	keybind.Initialize(X)
	// Create a new window. We will listen for key presses and
	// translate them only when this window is in focus.
	win, err := xwindow.Generate(X)
	if err != nil {
		log.Fatalf("Could not generate a new window X id: %s", err)
	}

	/* -------------------------- Define Rebind Window -------------------------- */

	// Variables for window properties
	/* 	var (
		// The geometry of the canvas to draw text on.
		canvasWidth, canvasHeight = 600, 100
		// The background color of the canvas.
		bg = xgraphics.BGRA{B: 0xff, G: 0x66, R: 0x33, A: 0xff}
		// The path to the font used to draw text.
		fontPath = "fonts/FreeMonoBold.ttf"
		// The color of the text.
		fg = xgraphics.BGRA{B: 0xff, G: 0xff, R: 0xff, A: 0xff}
		// The size of the text.
		size = 20.0
		// The text to draw.
		msg = "This is some text drawn by xgraphics!"
	) */
	win.Create(X.RootWin(), 0, 0, 500, 500, xproto.CwBackPixel, 0xffffffff)
	// Listen for Key{Press,Release} events.
	win.Listen(xproto.EventMaskKeyPress, xproto.EventMaskKeyRelease)
	// Map the window.
	win.Map()
	// Find the window ID
	wid := win.Id

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
				win.Destroy()
			// Hotkey with modifiers
			case len(modStr) > 0 && modStr != "mod2":
				newHotkey := modStr + "+" + keyStr
				log.Println("New Hotkey (with modifiers): ", newHotkey)
			// Hotkey without modifiers
			default:
				newHotkey := keyStr
				log.Println("New Hotkey: ", newHotkey)
			}
		}).Connect(X, wid)
	// Start the event loop to listen for rebind keys.
	// This will route events to the callback function.
	log.Println("Ready. Press the key(s) you wish to use for the hotkey.")
	xevent.Main(X)
}

/* -------------------------------------------------------------------------- */
/*                                   Example                                  */
/* -------------------------------------------------------------------------- */

/* func DrawText() {
	X, err := xgbutil.NewConn()
	if err != nil {
		log.Fatal(err)
	}
	// Load some font. You may need to change the path depending upon your
	// system configuration.
	fontReader, err := os.Open(fontPath)
	if err != nil {
		log.Fatal(err)
	}
	// Now parse the font.
	font, err := xgraphics.ParseFont(fontReader)
	if err != nil {
		log.Fatal(err)
	}
	// Create some canvas.
	ximg := xgraphics.New(X, image.Rect(0, 0, canvasWidth, canvasHeight))
	ximg.For(func(x, y int) xgraphics.BGRA {
		return bg
	})
	// Now write the text.
	_, _, err = ximg.Text(10, 10, fg, size, font, msg)
	if err != nil {
		log.Fatal(err)
	}
	// Compute extents of first line of text.
	_, firsth := xgraphics.Extents(font, size, msg)
	// Now show the image in its own window.
	win := ximg.XShowExtra("Drawing text using xgraphics", true)
	// Now draw some more text below the above and demonstrate how to update
	// only the region we've updated.
	_, _, err = ximg.Text(10, 10+firsth, fg, size, font, "Some more text.")
	if err != nil {
		log.Fatal(err)
	}
	// Now compute extents of the second line of text, so we know which region
	// to update.
	secw, sech := xgraphics.Extents(font, size, "Some more text.")
	// Now repaint on the region that we drew text on. Then update the screen.
	bounds := image.Rect(10, 10+firsth, 10+secw, 10+firsth+sech)
	ximg.SubImage(bounds).(*xgraphics.Image).XDraw()
	ximg.XPaint(win.Id)
	// All we really need to do is block, which could be achieved using
	// 'select{}'. Invoking the main event loop however, will emit error
	// message if anything went seriously wrong above.
	xevent.Main(X)
}

*/
