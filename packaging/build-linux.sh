#!/bin/bash

echo -e "Nyrna build script for Linux \n"

# Generic callable confirm function.
confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


# Confirm tests were run.
if confirm "Did you run tests? [y/N]"; then
    echo
else
    echo "Run tests first." && exit
fi


# Confirm version number has been updated.
if confirm "Did you update version number (constant, pubspec, changelog)? [y/N]"; then
    echo
else
    echo "Update version number first." && exit
fi


# Build
echo -e "Starting build.. \n"


cd ..

flutter clean

flutter pub get

flutter build linux

cd build/linux/release/ || cd build/linux/x64/release/

mv bundle nyrna

tar -zcvf nyrna.tar.gz nyrna

rm -rf nyrna
