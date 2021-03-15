---
title: Usage
layout: single
permalink: /usage
---


<br>


# Games

**Dark Souls**  
*Not letting me pause is not a difficulty, its user-hostile!*  
{% include video id="9OESJGBEmOY" provider="youtube" %}


<br>


# Applications

**Blender**  
*Ah geez, I have a Zoom meeting and my system is bogged down with a render..*  
{% include video id="Q2Pn1VA-2YA" provider="youtube" %}


<br>


# Advanced

## Toggle active window

Nyrna can be used to toggle the suspend / resume state of one active window by
setting a hotkey to launch Nyrna with the `-t` or `--toggle` flag.

Once the hotkey is set, simply press that key to have the window of your
currently active application suspended. A subsequent press will resume that
application.


**Linux Example**

{% capture linux-example-text %}
- Shortcuts ->
- Custom Shortcuts ->
  - Edit ->
    - New ->
      - Global Shortcut
        - Action: `/path/to/nyrna -t`

![KDE custom shortcut](assets/images/custom-shortcut-linux-kde.png)
{% endcapture %}

<div class="notice--info">
  <h4 class="no_toc">KDE System Settings:</h4>
  {{ linux-example-text | markdownify }}
</div>


**Windows Example**

{% capture windows-example-text %}
- Right click shortcut -> Properties
- Shortcut tab
  - Target -> Edit ending to include `-t` or `--toggle`, like: 
    `C:\Nyrna\nyrna.exe -t`
  - Shortcut key -> Choose key to trigger the toggle function
    - Apply

![Windows custom shortcut](assets/images/custom-shortcut-windows.png)
{% endcapture %}

<div class="notice--info">
  <h4 class="no_toc">Create or edit Nyrna shortcut:</h4>
  {{ windows-example-text | markdownify }}
</div>
