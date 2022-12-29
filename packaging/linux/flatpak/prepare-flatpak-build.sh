#!/bin/bash

# Expand variables and echo all commands
set -x

# ---------------------------------------------------------------------------- #
#                  Prepare the environment for a Flatpak build                 #
# ---------------------------------------------------------------------------- #

projectId=codes.merritt.Nyrna
# repository=nyrna
# githubUsername=merrit

# Get shared modules
gh repo clone flathub/shared-modules

# Automatic recipe update disabled because the updater cannot currently handle a
# yaml manifest or Flatpak submodules. Will revisit feasability.

# Update AppStream metadata and Flathub manifest files.
# dart pub global activate --source path /home/merritt/Development/linux_packaging_updater
# updater --projectId $projectId --repository $repository --user $githubUsername --verbose
# dart pub global activate --source git https://github.com/Merrit/linux_packaging_updater.git
# updater $projectId $repository $githubUsername

# Verify AppStream metadata file for Flathub.
flatpak run org.freedesktop.appstream-glib validate $projectId.metainfo.xml
