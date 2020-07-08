package main

import (
	"runtime"

	"github.com/adrg/xdg"
)

// OS constant since we repeatedly check which
// platform we are currently running under.
// Maybe this is not necessary - does GOOS
// get set just once?
const OS string = runtime.GOOS

// XDG path to place the suspended process info
// Linux: ~/.cache/Nyrna/suspended.txt
// Mac: ~/Library/Caches/Nyrna/suspended.txt
// Windows: %LOCALAPPDATA%\cache\Nyrna\suspended.txt
func getSavedProcessFilePath() string {
	cacheFilePath, err := xdg.CacheFile("Nyrna/suspended.txt")
	if err != nil {
		// Treat error.
	}
	return cacheFilePath
}

// SavedProcessFile is the file that will contain the name
// and PID of the suspended process. It is a variable because
// Golang can't assign constants with a function..
var SavedProcessFile string = getSavedProcessFilePath()

// ConfigFilePath is the XDG path for the config file
// Linux: ~/.config/nyrna_config.json
// Mac: ~/Library/Preferences/nyrna_config.json
// Windows: %LOCALAPPDATA%\nyrna_config.json
var ConfigFilePath string = xdg.ConfigHome
