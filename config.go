package main

import (
	"log"

	// Third Party Libraries
	"github.com/spf13/viper"
)

// ConfigLoad ...
func ConfigLoad() (hotkey string) {
	viper.SetConfigName("nyrna_config")
	viper.SetConfigType("json")
	viper.AddConfigPath(ConfigFilePath)
	viper.SetDefault("hotkey", "Pause")
	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		Check(err)
	}
	hotkey = viper.GetString("hotkey")
	log.Println("Saved hotkey is:", hotkey)
	return hotkey
}

// ConfigLoadWindows ...
func ConfigLoadWindows() (hotkey uint16) {
	viper.SetConfigName("nyrna_config")
	viper.SetConfigType("json")
	viper.AddConfigPath(ConfigFilePath)
	viper.SetDefault("hotkey", "Pause")
	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		Check(err)
	}
	hotkey = uint16(viper.GetUint("hotkey"))
	log.Println("Saved hotkey is:", hotkey)
	return hotkey
}

// ConfigWrite ...
func ConfigWrite(newHotkey string) {
	viper.Set("hotkey", newHotkey)
	configFile := ConfigFilePath + "/nyrna_config.json"
	viper.WriteConfigAs(configFile)
}

// ConfigWriteWindows ...
func ConfigWriteWindows(newHotkey uint16) {
	viper.Set("hotkey", newHotkey)
	configFile := ConfigFilePath + "/nyrna_config.json"
	viper.WriteConfigAs(configFile)
}

// ConfigRead ...
func ConfigRead() {

}
