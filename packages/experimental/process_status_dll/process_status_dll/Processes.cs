using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

// This works and is clean, however it is quite slow at getting the suspended state.
//
// Getting the status of just 4 or 5 processes takes ~7 - 10 seconds, compared to less than
// half that for a PowerShell call directly from dart.

namespace process_status_dll
{
    static public class Processes
    {
        static public String check()
        {
            var processes = Process.GetProcesses();
            foreach (Process process in processes)
            {
                var shouldFilter = filteredWindows.Contains(process.ProcessName);
                if (shouldFilter) continue;
                var hasNoTitle = (process.MainWindowTitle != "");
                if (hasNoTitle) continue;
                var pid = process.Id;
                var name = process.ProcessName;
                var windowTitle = process.MainWindowTitle;
                var threadsWaiting = threadsAreWaiting(process.Threads);
                var suspended = (threadsWaiting) ? threadsAreSuspended(process.Threads) : false;
                Console.WriteLine(
                    $"pid: {pid},\n" +
                    $"name: {name}\n" +
                    $"windowTitle: {windowTitle}\n" +
                    $"suspended: {suspended}\n"
                );
            }
            return "boop";
        }

        private static bool threadsAreWaiting(ProcessThreadCollection threads) {
            foreach(ProcessThread thread in threads)
            {
                if (thread.ThreadState != ThreadState.Wait) return false;
            }
            return true;
        }

        private static bool threadsAreSuspended(ProcessThreadCollection threads)
        {
            foreach (ProcessThread thread in threads)
            {
                if (thread.WaitReason != ThreadWaitReason.Suspended) return false;
            }
            return true;
        }

        private static List<String> filteredWindows = new List<String> {
            "nyrna",
            "ApplicationFrameHost", // Manages UWP (Universal Windows Platform) apps
            "Calculator",
            "devenv",
            "explorer", // Windows File Explorer
            "googledrivesync",
            "HxCalendarAppImm",
            "HxOutlook",
            "LogiOverlay", // Logitech Options
            "Microsoft.Notes",
            "PenTablet", // XP-PEN driver
            "perfmon", // Resource Monitor
            "Rainmeter",
            "SystemSettings", // Windows system settings
            "Taskmgr", // Windows Task Manager
            "TextInputHost", // Microsoft Text Input Application
            "VsDebugConsole",
            "WinStore.App", // Windows Store
        };
    }
}
