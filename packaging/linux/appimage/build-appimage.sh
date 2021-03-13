#!/bin/bash

#===========
# Call script with `source ./build-appimage.sh`
#===========


# Set the VERSION environment variable.
export APP_VERSION=2.0-beta.1

# Build the AppImage from the AppImageBuilder.yml
appimage-builder --skip-test
