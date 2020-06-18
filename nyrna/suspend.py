# Standard Library
import os
import pickle
import subprocess
import sys

# Third Party Libraries
import psutil

# Nyrna Modules
from constant import user_cache_dir, user_data_dir
from nyrna_logger import log


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
            os.makedirs(user_data_dir, exist_ok=True)
            saved_process_file = open(
                os.path.join(user_data_dir, "paused_app.pkl"), "rb"
            )
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
        xdotool_pid = subprocess.run(
            ["xdotool", "getwindowfocus", "getwindowpid"],
            stdout=subprocess.PIPE,
            text=True,
        )
        pid = int(xdotool_pid.stdout.strip())
        xdotool_active_window_name = subprocess.run(
            ["xdotool", "getwindowfocus", "getwindowname"],
            stdout=subprocess.PIPE,
            text=True,
        )
        active_window_name = xdotool_active_window_name.stdout.strip()
        if "explorer.exe" and "WineDesktop" not in active_window_name:
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
            os.makedirs(user_data_dir, exist_ok=True)
            os.remove(os.path.join(user_data_dir, "paused_app.pkl"))
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
            os.makedirs(user_data_dir, exist_ok=True)
            saved_process_file = open(
                os.path.join(user_data_dir, "paused_app.pkl"), "wb"
            )
            pickle.dump(save_values, saved_process_file, pickle.HIGHEST_PROTOCOL)
            saved_process_file.close()


# hotkey.py listens for the hotkey,
# then calls this function.
def toggle_suspend():
    process = Process()
    process.toggle_suspend()
