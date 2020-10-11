package main

import (
	"fmt"
	"log"
)

// Check is a helper to make checking for
// simple errors cleaner and easier.
func Check(e error) {
	if e != nil {
		errorText := fmt.Sprintf("Caught an error: %v", e)
		log.Println(errorText)
	}
}
