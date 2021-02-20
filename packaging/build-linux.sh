#!/bin/bash

function version_check {
    echo "Did you update the version number in globals.dart, README, etc?"
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) echo "Great! Starting build.."; break;;
            [Nn]*) echo "Update version first."; exit;;
        esac
    done
}

version_check

cd ..

flutter clean

flutter pub get

flutter build linux

cd build/linux/release/ || cd build/linux/x64/release/

mv bundle nyrna

tar -zcvf nyrna.tar.gz nyrna

rm -rf nyrna