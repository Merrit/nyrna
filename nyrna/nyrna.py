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
Wnck (Install libwnck3 from package manager)

For Windows (IN PROGRESS - not yet implemented):
Make sure win32gui is available
TODO: This package now appears to be part of pywin32, so you need to import pywin32 and call win32gui?

For Mac (May be possible to support in the future):
Make sure AppKit is available
"""


# Standard Library
import logging
import logging.handlers
import pickle
import sys
import os


# Third Party Libraries
import psutil


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


class Process:

    """
    Object representing the process for which 
    we want to toggle suspend / resume.
    """

    def __init__(self):
        self.operating_system = self.get_operating_system()
        self.process = self.check_for_saved_process()

    def get_operating_system(self):
        """ Determine the operating system """
        if sys.platform in ["linux", "linux2"]:
            return "linux"
        elif sys.platform in ["Windows", "win32", "cygwin"]:
            return "windows"
        elif sys.platform in ["Mac", "darwin", "os2", "os2emx"]:
            # return "mac"
            log("OS 'Mac' is not currently supported!")
            raise Exception
        else:
            log("Unable to determine operating system.")
            log("sys.platform is:")
            log(sys.platform)
            raise Exception

    def check_for_saved_process(self):
        """ Check if a saved process file exists from a previous suspend """
        try:
            saved_process_file = open(os.path.join(sys.path[0], "paused_app.pkl"), "rb")
            saved_process = pickle.load(saved_process_file)  # Saved dictionary
            log("Opened paused_app.pkl:")
            log(saved_process)
            saved_name = saved_process["name"]
            saved_pid = saved_process["pid"]
            log(f"saved_name: {saved_name}")
            log(f"saved_pid: {saved_pid}")
            # Check if same process still exists
            process_name = str(psutil.Process(saved_pid).name())
            log(f"process name: {process_name}")
            if saved_name == process_name:
                # Return the current process with an updated status
                return psutil.Process(saved_pid)
        except:
            log("There is no paused_app.pkl, getting active window")
            return self.get_active_window()

    def get_active_window(self):
        """ Call a method to find the window based on the OS """
        if self.operating_system == "linux":
            return self.get_active_window_linux()
        elif self.operating_system == "windows":
            return self.get_active_window_windows()

    def get_active_window_linux(self):
        """ Find the process of the active window on Linux """
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
        # Check if we found a Wine process with virtual desktop enabled
        if "explorer.exe" not in active_window_name:
            return psutil.Process(pid)
        else:
            return self.find_wine_process()

    def find_wine_process(self):
        """ Suspending explorer.exe (virtual desktop setting) 
        does nothing, so we need to find the real process """
        wineserver_processes = []
        # Check if any running process is a wineserver
        for process in psutil.process_iter():
            if "wineserver" in process.name():
                wineserver_processes.append(process)
        if len(wineserver_processes) == 1:
            wineserver_process = wineserver_processes[0]
            wineserver_PID = wineserver_process.pid
            # List files opened by wineserver,
            # The executable we need should be one of them
            files = psutil.Process(wineserver_PID).open_files()
            file_path = None
            # Find which file is the executable of the Windows program
            for item in files:
                if "exe" in str(item):
                    file_path = str(item)
            log(f"Wine - file_path: {file_path}")
            # Parse the actual application name from all the path text
            split_file_path = file_path.rsplit(".exe", 1)
            split_file_path = split_file_path[0].split("/")
            wine_app_name = split_file_path[-1]
            log(f"Wine - split_file_path: {split_file_path}")
            log(f"Wine - executable name: {wine_app_name}")
            # Find a running process that contains the application name
            for process in psutil.process_iter():
                if wine_app_name in process.name():
                    wine_process = process
            return wine_process
        else:
            # If there are multiple wineserver processes,
            # how would we determine which is the one we need?
            log("Error: Found multiple wineserver processes")
            raise Exception

    def get_active_window_windows(self):
        """ Find the process of the active window on Windows """
        pass

    def toggle_suspend(self):

        """
        Toggle suspend/resume for the process.
        After suspending, the process object will be saved to disk
        so we can check if anything needs to be resumed in the case
        that the suspended window can't be refocused.
        """

        if self.process.status() == "stopped":  # Resume
            psutil.Process(self.process.pid).resume()
            log(f"Resumed process has name: {self.process.name()}")
            log(f"Resumed process has PID: {self.process.pid}")
            # Remove the saved object from disk so as
            # to not cause confusion for next time
            os.remove(os.path.join(sys.path[0], "paused_app.pkl"))
        else:  # Suspend
            psutil.Process(self.process.pid).suspend()
            log(f"Suspended process has name: {self.process.name()}")
            log(f"Suspended process has PID: {self.process.pid}")
            # Save the process we found, so we can check for which
            # process to resume in case the window can't be focused.
            # Not being able to focus after suspend has been a frequent issue with games.
            save_values = {}  # Save to dict since we can't pickle the psutil object
            save_values["pid"] = self.process.pid
            save_values["name"] = self.process.name()
            saved_process_file = open(os.path.join(sys.path[0], "paused_app.pkl"), "wb")
            pickle.dump(save_values, saved_process_file, pickle.HIGHEST_PROTOCOL)
            saved_process_file.close()


new_process = Process()

new_process.toggle_suspend()
