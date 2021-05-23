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


<!-- Packages need to be updated for Nyrna 2.0
## Packages

### Arch / Manjaro          # AUR package needs a maintainer

A package is available [in the AUR](https://aur.archlinux.org/packages/nyrna/).

- `yay nyrna`

### Gentoo

A package is available as [nyrna](https://github.com/BlueManCZ/edgets/tree/master/x11-misc/nyrna) or [nyrna-bin](https://github.com/BlueManCZ/edgets/tree/master/x11-misc/nyrna-bin) in the [edgets overlay](https://github.com/BlueManCZ/edgets).

- `layman --add edgets && emerge --ask nyrna`
-->

## AppImage

[Download AppImage](https://github.com/Merrit/nyrna/releases/download/v2.0.0-beta.3/Nyrna-2.0.0-beta.3-x86_64.AppImage){: .btn .btn--info}

## Snap

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/nyrna)

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
[Download Linux portable](https://github.com/Merrit/nyrna/releases/download/v2.0.0-beta.3/nyrna-linux-portable-2.0.0-beta.3.zip){: .btn .btn--info}

<br>


Windows
=======

## Installer

[Download Installer exe](https://github.com/Merrit/nyrna/releases/download/v2.0.0-beta.3/nyrna-windows-installer-2.0.0-beta.3.zip){: .btn .btn--info}

<!--                # Chocolatey needs updating for Nyrna 2.0
## Chocolatey

<https://chocolatey.org/packages/nyrna>

`choco install nyrna`
-->

## Portable

[Download Windows portable](https://github.com/Merrit/nyrna/releases/download/v2.0.0-beta.3/nyrna-windows-portable-2.0.0-beta.3.zip){: .btn .btn--info}
