#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Simple tray icon for Windows that monitors for the user to press
; the `Pause` keyboard key, then activates Nyrna's `toggle active` function.

Menu, Tray, NoStandard
Menu, Tray, Add, Exit
Menu, Tray, Tip, Nyrna - Toggle Active Hotkey
Menu, Tray, Icon, data\flutter_assets\assets\icons\nyrna.ico

Pause::
    Run, toggle_active_window.exe
Return

Exit:
ExitApp
Return
