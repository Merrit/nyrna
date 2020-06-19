#!/usr/bin/env python

"""
Nyrna - Suspend any game or application.
Copyright (C) 2020  Kristen McWilliam

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. 
"""


"""
Credit for starting point of how to find the active window:
https://stackoverflow.com/a/36419702/9872288


Prerequisites

All platforms:
- Python 3
    - psutil (pip3 install psutil)
    - pynput (pip3 install pynput)
    - PySimpleGUI (pip3 install pysimplegui)

For Linux:
- xdotool (sudo apt install xdotool, or sudo pacman -S xdotool)

For Windows (IN PROGRESS - not yet implemented):
Make sure win32gui is available
TODO: This package now appears to be part of pywin32, so you need to import pywin32 and call win32gui?

For Mac (May be possible to support in the future):
Make sure AppKit is available
"""


# Nyrna Modules
from gui import systray
import hotkey


nyrna_hotkey = hotkey.HotKey()
nyrna_tray = systray.SysTray()
