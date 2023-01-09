#!/bin/bash


# When run from the vscode dev container this will build a .flatpak of the app.


set -x


projectName=Nyrna
projectId=codes.merritt.Nyrna

archiveName=$projectName-Linux-Portable.tar.gz

# ----------------------------- Build Flutter app ---------------------------- #

flutter pub get
flutter build linux

workspace=$PWD
cd build/linux/x64/release/bundle || exit
touch PORTABLE
tar -czaf $archiveName ./*
cp -r $archiveName "$workspace"/packaging/linux/flatpak/
cd "$workspace" || exit

# ------------------------------- Build Flatpak ------------------------------ #

cd packaging/linux/flatpak || exit

# Copy the AppStream file to the flatpak dir for build.
cp -r ../"$projectId".metainfo.xml .

flatpak-builder --force-clean build-dir $projectId.yml --repo=repo
flatpak build-bundle repo $projectId.flatpak $projectId

# Remove the AppStream file from the flatpak dir after build.
rm "$projectId".metainfo.xml
