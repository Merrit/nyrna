package main

import (
	"log"
)

// Check is a helper to make checking for
// simple errors cleaner and easier.
func Check(e error) {
	if e != nil {
		log.Println(e)
	}
}
