#!/bin/bash

# Convert the archive of the Flutter app to a Flatpak.
#
# This script runs INSIDE the flatpak-builder sandbox.
# It expects:
#   - Nyrna-Linux-Portable.tar.gz  (pre-built Flutter bundle)
#   - assets/icons/codes.merritt.Nyrna.svg
#   - packaging/linux/codes.merritt.Nyrna.desktop
#   - packaging/linux/codes.merritt.Nyrna.metainfo.xml

set -e
set -x

projectName=Nyrna
projectId=codes.merritt.Nyrna
executableName=nyrna

# ------------------------------- Build Flatpak ----------------------------- #

# Extract portable Flutter build.
mkdir -p $projectName
tar -xf $projectName-Linux-Portable.tar.gz -C $projectName

# Copy the portable app to the Flatpak-based location.
cp -r $projectName /app/
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon.
iconDir=/app/share/icons/hicolor/scalable/apps
mkdir -p $iconDir
cp -r assets/icons/$projectId.svg $iconDir/

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp -r packaging/linux/$projectId.desktop $desktopFileDir/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp -r packaging/linux/$projectId.metainfo.xml $metadataDir/
