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
Python 3
psutil (pip install psutil)

For Linux:
Install wnck (sudo apt-get install python-wnck on Ubuntu, see libwnck.)
TODO: This doesn't actually seem to be necessary, since I have been using it without.
Manjaro came with PyGObject/gi installed by default, and it has been working fine. Should we worry about wnck at all?
Is one more performant than the other?

For Windows (IN PROGRESS - not yet implemented):
Make sure win32gui is available
TODO: This package now appears to be part of pywin32, so you need to import pywin32 and call win32gui?

For Mac (May be possible to support in the future):
Make sure AppKit is available
"""


import logging
import logging.handlers
import sys
import psutil
import os
import pickle


# Since this runs via hotkey there is no terminal to
# print to, we need a logger for debugging.
LOG_FILENAME = os.path.join(sys.path[0], "nyrna.log")
logger = logging.getLogger("Logger")
logger.setLevel(logging.DEBUG)
handler = logging.handlers.RotatingFileHandler(
    filename=LOG_FILENAME, maxBytes=1000000, backupCount=2, encoding="utf-8"
)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


def log(logMessage):
    # Easier way to call the debug logger:
    # log("message")
    return logger.debug(logMessage)


def get_active_window():

    # TODO: Refactor to seperate classes / functions / files / etc.

    """
    Get the currently active window and accompanying process information.

    Returns a dictionary (return_values) with the information, eg. PID, process name, process status, etc.
    """

    return_values = {}

    active_window_name = None

    if sys.platform in ["linux", "linux2"]:
        # Alternatives: http://unix.stackexchange.com/q/38867/4784
        try:
            import wnck
        except ImportError:
            log("wnck not installed")
            wnck = None
        if wnck is not None:
            screen = wnck.screen_get_default()
            screen.force_update()
            window = screen.get_active_window()
            if window is not None:
                pid = window.get_pid()
                with open("/proc/{pid}/cmdline".format(pid=pid)) as f:
                    active_window_name = f.read()
        else:
            try:
                from gi.repository import Gtk, Wnck

                gi = "Installed"
            except ImportError:
                log("gi.repository not installed")
                gi = None
            if gi is not None:
                Gtk.init([])  # necessary if not using a Gtk.main() loop
                screen = Wnck.Screen.get_default()
                screen.force_update()  # recommended per Wnck documentation
                active_window = screen.get_active_window()
                pid = active_window.get_pid()
                with open("/proc/{pid}/cmdline".format(pid=pid)) as f:
                    active_window_name = f.read()

    # Did we receive a Wine process with virtual desktop enabled?
    # Suspending explorer.exe (virtual desktop setting) does nothing, so we need to find the real process.
    if "explorer.exe" in active_window_name:
        log(f"active_window_name: {active_window_name}")
        explorer_parent_PID = psutil.Process(pid).ppid()
        log(f"Parent PID: {explorer_parent_PID}")
        parent_process = psutil.Process(explorer_parent_PID)
        log(f"Parent process: {parent_process}")

        # TODO: See if this is still needed now that the generic Wine method is available.
        if "lutris" in psutil.Process(explorer_parent_PID).name():
            lutris_child = psutil.Process(explorer_parent_PID).children()[0]
            log(f"Lutris child: {lutris_child}")
            lutris_child_PID = lutris_child.pid
            log(f"Lutris child PID: {lutris_child_PID}")
            return_values["pid"] = lutris_child_PID
        else:  # Generic way to find the wine process
            wineserver_processes = []
            for process in psutil.process_iter():
                if "wineserver" in process.name():
                    wineserver_processes.append(process)
            if len(wineserver_processes) == 1:
                wineserver_process = wineserver_processes[0]
                wineserver_PID = wineserver_process.pid
                log(f"wineserver_PID: {wineserver_PID}")
                wine_process_PID = find_wine_process(wineserver_PID)
                return_values["pid"] = wine_process_PID
            else:
                log("Error: Found multiple wineserver processes")

    elif sys.platform in ["Windows", "win32", "cygwin"]:
        # http://stackoverflow.com/a/608814/562769
        import win32gui

        window = win32gui.GetForegroundWindow()
        active_window_name = win32gui.GetWindowText(window)
    elif sys.platform in ["Mac", "darwin", "os2", "os2emx"]:
        # http://stackoverflow.com/a/373310/562769
        from AppKit import NSWorkspace

        active_window_name = NSWorkspace.sharedWorkspace().activeApplication()[
            "NSApplicationName"
        ]
    else:
        print(
            "sys.platform={platform} is unknown. Please report.".format(
                platform=sys.platform
            )
        )
        print(sys.version)

    if "pid" in return_values:
        log("Process is Wine with virtual desktop")
    else:
        return_values["pid"] = pid

    return_values["active_window_name"] = active_window_name

    return return_values


def find_wine_process(wineserver_PID):

    """
    Find the real Wine process when get_active_window()
    finds explorer.exe (emulated virtual desktop).
    
    This is necessary because pausing explorer.exe has
    no effect on the real Wine process.

    Returns the PID of the actual Wine process.
    """

    # List files opened by wineserver
    files = psutil.Process(wineserver_PID).open_files()

    file_path = ""

    # Find which file is the executable of the Windows program
    for item in files:
        if "exe" in str(item):
            file_path = item

    log(f"file_path: {file_path}")

    file_path = str(file_path)

    # Parse the actual application name
    split_file_path = file_path.rsplit(".exe", 1)
    split_file_path = split_file_path[0].split("/")
    wine_app_name = split_file_path[-1]

    log(f"split_file_path: {split_file_path}")
    log(f"Wine app name: {wine_app_name}")

    # Find a running process that contains the application name
    for process in psutil.process_iter():
        if wine_app_name in process.name():
            wine_process_PID = process.pid

    return wine_process_PID


def suspend_process():

    """
    Toggle suspend/resume for the active, foreground window.
    """

    process_values = None

    # Check if a saved process file exists from previous suspend.
    try:
        saved_process_file = open(os.path.join(sys.path[0], "paused_app.pkl"), "rb")
        process_values = pickle.load(saved_process_file)
        log("Opened paused_app.pkl:")
        log(process_values)
    except:
        log("There is no paused_app.pkl, getting active window")
        process_values = get_active_window()
        log(process_values)

    # Get the current process status.
    pid = process_values["pid"]
    process_values["process_status"] = psutil.Process(pid).status()
    process_status = process_values["process_status"]
    log(f"Process status: {process_status}")

    # Suspend or resume the process.
    if process_status == "stopped":
        psutil.Process(process_values["pid"]).resume()
        log(f"Resumed process: {pid}")
        os.remove(os.path.join(sys.path[0], "paused_app.pkl"))
    else:
        psutil.Process(process_values["pid"]).suspend()
        log(f"Suspended process: {pid}")

        # Save the dictionary with the values we found, so we can check
        # for which process to resume in case the window can't be focused.
        # Not being able to focus after suspend has been a frequent issue with games.
        saved_process_file = open(os.path.join(sys.path[0], "paused_app.pkl"), "wb")
        pickle.dump(process_values, saved_process_file, pickle.HIGHEST_PROTOCOL)
        saved_process_file.close()


suspend_process()
