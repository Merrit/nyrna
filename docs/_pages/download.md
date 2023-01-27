---
title: Download Nyrna
layout: single
permalink: /download
toc: true
toc_label: Download options
toc_icon: fas fa-file-download
toc_sticky: true
---


<br>


Linux
=====


## Flatpak

<a href='https://flathub.org/apps/details/codes.merritt.Nyrna'><img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>

## Portable

{% capture requirements-text %}
- libgtk-3-0
- libblkid1
- liblzma5
- wmctrl
- xdotool

Example (Debian / Ubuntu):  
`sudo apt install libgtk-3-0 libblkid1 liblzma5 wmctrl xdotool`
{% endcapture %}

<div class="notice--info">
  <h4 class="no_toc">Portable Requirements:</h4>
  {{ requirements-text | markdownify }}
</div>

<!-- TODO: Figure out how to populate the version info for links automatically. -->
[Download Linux portable](https://github.com/Merrit/nyrna/releases/latest/download/Nyrna-Linux-Portable.tar.gz){: .btn .btn--info}

<br>


Windows
=======

## Microsoft Store

*Purchase from the Microsoft Store for automatic updates and to support my work.*

<a href="ms-windows-store://pdp/?ProductId=9P9S8KZ41GRJ&mode=mini">
   <img src="https://get.microsoft.com/images/en-us%20dark.svg" width='240' alt="Download Nyrna" />
</a>

## Installer

[Download Installer exe](https://github.com/Merrit/nyrna/releases/latest/download/Nyrna-Windows-Installer.exe){: .btn .btn--info}

## Portable

[Download Windows portable](https://github.com/Merrit/nyrna/releases/latest/download/Nyrna-Windows-Portable.zip){: .btn .btn--info}
