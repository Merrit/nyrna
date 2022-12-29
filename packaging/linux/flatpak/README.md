`prepare-flatpak-build.sh` will update the values in the yml and xml recipe
files for the latest published release.

`build-flatpak.sh` will use flatpak-builder to construct the flatpak if invoked
manually, however it is intended to be run by the Flathub bot when these updated
files are pushed to the repo at
https://github.com/flathub/codes.merritt.Nyrna
