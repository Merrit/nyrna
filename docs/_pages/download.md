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

## AppImage

*Supports auto-update*

[Download AppImage](){: .btn .btn--info}

<!-- Packages need to be updated for Nyrna 2.0
## Packages

### Arch / Manjaro          # AUR package needs a maintainer

A package is available [in the AUR](https://aur.archlinux.org/packages/nyrna/).

- `yay nyrna`

### Gentoo

A package is available as [nyrna](https://github.com/BlueManCZ/edgets/tree/master/x11-misc/nyrna) or [nyrna-bin](https://github.com/BlueManCZ/edgets/tree/master/x11-misc/nyrna-bin) in the [edgets overlay](https://github.com/BlueManCZ/edgets).

- `layman --add edgets && emerge --ask nyrna`
-->

## Snap

*Pending approval in the snap store.*

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

[Download Linux portable](https://github.com/Merrit/nyrna/releases/latest/download/nyrna.tar.gz){: .btn .btn--info}

<br>


Windows
=======

## Installer

[Download Installer exe](){: .btn .btn--info}


## winget

*Add command*

<!--                # Chocolatey needs updating for Nyrna 2.0
## Chocolatey

<https://chocolatey.org/packages/nyrna>

`choco install nyrna`
-->

## Portable

[Download Windows portable](){: .btn .btn--info}