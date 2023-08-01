---
title: Usage
layout: single
permalink: /usage
---


<br>


# Video examples

## Games

**Dark Souls**  
*No pause feature? What if I need to answer the phone?*  
[![Dark Souls example](../assets/images/demo-dark-souls.jpg)](https://www.youtube.com/watch?v=9OESJGBEmOY)


<br>


## Applications

**Blender**  
*Time for my Zoom meeting and my system is bogged down with a render..*  
[![Blender example](../assets/images/demo-blender.jpg)](https://www.youtube.com/watch?v=Q2Pn1VA-2YA)


<br>


# Advanced

## Toggle active window

Nyrna can be used to toggle the suspend / resume state of one active window:

- Windows
  - In settings enable `Close to tray`, and configure a hotkey. While Nyrna is
    opened or in the system tray this hotkey will trigger suspend/resume for the
    actively focused window.
    - You can also set Nyrna to run automatically when you sign in.

- Linux
  - Set a hotkey in system settings to run the nyrna executable with the
    `--toggle` flag, example:
    > ~/Applications/Nyrna/nyrna --toggle
  
  or

  - Set a hotkey in Nyrna's settings the same way as for Windows.

Now simply press the hotkey on your keyboard to have the window of your
currently active application suspended. A subsequent press will resume that
application.

**Tip:** You can use something like
[AntiMicro](https://github.com/AntiMicro/antimicro) to trigger this hotkey with
your gamepad, allowing you to suspend/resume your game with just your controller.


**Linux Example**

KDE System Settings:

- Shortcuts ->
- Custom Shortcuts ->
  - Edit ->
    - New ->
      - Global Shortcut
        - Action: `/path/to/nyrna/nyrna_toggle_active_window`

![KDE custom shortcut](../assets/images/custom-shortcut-linux-kde.png)
