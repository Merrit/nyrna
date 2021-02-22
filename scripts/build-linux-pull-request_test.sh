#!/bin/sh

# Use `act` to do a local test of GitHub actions.
# https://github.com/nektos/act
#
# Much better to test an action locally instead of after commiting.

cd ..

sudo act pull_request -P ubuntu-latest=nektos/act-environments-ubuntu:18.04
