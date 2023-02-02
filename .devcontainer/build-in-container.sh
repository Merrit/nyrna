#!/bin/bash


# When run from the vscode dev container this will build and package the app.


set -x


projectName=Nyrna
archiveName=$projectName-Linux-Portable.tar.gz

# ----------------------------- Build Flutter app ---------------------------- #

flutter pub get
flutter build linux

workspace=$PWD
cd build/linux/x64/release/bundle || exit
touch PORTABLE
tar -czaf $archiveName ./*
cp -r $archiveName "$workspace"/
cd "$workspace" || exit
