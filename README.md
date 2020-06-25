# Nyrna

**Nyrna allows the user to pause any game or application on their PC.**

The reason for this project is to have a function on PC similar to the incredibly useful sleep/suspend function found in consoles like the Nintendo Switch and Sony PlayStation; suspend your game (and its resource usage) at any time, and resume whenever you wish - at the push of a button.

That said this can be used to pause normal, non-game applications as well. For example: while doing a long 3D render, or maybe a video encoding job, the CPU and GPU resources are being hogged by said task - maybe for hours - when you would like to use the system for something else. With Nyrna you can pause that program, freeing up the CPU and GPU resources (not RAM) until the process is resumed, without losing where you were.

Nyrna currently works on Linux. Windows support is in progress.

# Prerequisites

GNOME users may need to install `libappindicator3` with their package manager, since GNOME doesn't seem to ship with support for system tray icons. Example:

- Debian / Ubuntu: `sudo apt install libappindicator3-1`
- Arch / Manjaro: `sudo pacman -S libappindicator-gtk3`

# Usage

- [Download Nyrna](https://github.com/Merrit/nyrna/releases/latest/download/nyrna).
- Make sure it is set as executable and then click to run - it will run in your system tray.
- Press the `Pause` key on your keyboard to suspend the active, foreground application. Press again to resume the same application regardless of the current focus.

![Demo of Nyrna running as a Tray Icon](images/demo_nyrna_tray.png)

# Disclaimer

I have not had any issues using Nyrna, however keep in mind it is possible something could go wrong with a suspend. So please remember to always save your work and games.

# In case of issue

I haven't seen this issue, however if at any time the hotkey isn't working to resume, you can always manually find your process in task manager and resume or send signal SIGCONT / CONT:

![How to manually resume](images/demo_manual_resume.jpg)

# Planned Features

- ~~Run in system tray with hotkey configured by app~~ :heavy_check_mark:
- ~~Package(s) for ease of use~~ :heavy_check_mark:
- Windows support
- Simple way to customize hotkey

# FAQ

**Can I suspend to disk so that I can restore after reboot / free up RAM usage / etc?**

Unfortunately no. CRUI looks very promising to allow us to do this (on linux), however it [does not currently support suspending GUI applications](https://criu.org/X_applications).
