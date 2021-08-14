[<img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" height="40px" width="145" >](https://www.buymeacoffee.com/Merritt)


# Nyrna


**Suspend games and applications.**

![Nyrna interface](assets/../docs/assets/images/nyrna-window.png)

Similar to the incredibly useful sleep/suspend function found in consoles like the Nintendo Switch and Sony PlayStation; suspend your game (and its resource usage) at any time, and resume whenever you wish - at the push of a button.

Nyrna can be used to suspend normal, non-game applications as well. For example:

- 3D renders
- video encoding
- software compilation

The CPU and GPU resources are being used by said task - maybe for hours - when
you would like to use the system for something else. With Nyrna you can suspend
that program,
freeing up the resources (excluding RAM) until the process is resumed,
without losing where you were - like the middle of a long job, or a gaming session
between save points.

Nyrna works on Linux with X11 and Microsoft Windows (tested on Windows 10).


[Nyrna Website](https://nyrna.merritt.codes)


<!-- Still showing v1.3 as green. How to trigger update?
[![Packaging status](https://repology.org/badge/vertical-allrepos/nyrna.svg)](https://repology.org/project/nyrna/versions) -->


# Disclaimer

I have not had any issues using Nyrna, however keep in mind it is possible
something could go wrong with an application while suspended. So please remember to always save
your work and games.


# FAQ

**Can I suspend to disk so that I can restore after reboot / free up RAM usage / etc?**

Unfortunately no. [CRIU](https://criu.org/) looks very promising to allow us to do this (on Linux), however it [does not currently support suspending GUI applications](https://criu.org/X_applications).


# Compiling

See [COMPILING](COMPILING.MD)
