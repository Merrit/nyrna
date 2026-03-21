#!/bin/bash

# Build a Flatpak of Nyrna from local source for testing.
#
# This script:
#   1. Checks for flatpak-builder on the host
#   2. Builds the Flutter app
#   3. Packages it into a tarball
#   4. Runs flatpak-builder with the dev manifest (type: dir)
#   5. Installs the Flatpak for the current user
#
# Usage:
#   ./packaging/linux/flatpak/build-local.sh
#
# After a successful build:
#   flatpak run codes.merritt.Nyrna

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# ── Prerequisites ──

if ! command -v flatpak-builder &>/dev/null; then
    echo "ERROR: flatpak-builder not found."
    echo ""
    echo "Install it for your distro:"
    echo "  Fedora:  sudo dnf install flatpak-builder"
    echo "  Ubuntu:  sudo apt install flatpak-builder"
    echo "  Arch:    sudo pacman -S flatpak-builder"
    exit 1
fi

if ! command -v flutter &>/dev/null; then
    echo "ERROR: flutter not found on PATH."
    exit 1
fi

# Ensure Flatpak runtime & SDK are available.
echo "==> Ensuring Flatpak runtime and SDK are installed..."
flatpak install -y --noninteractive flathub \
    org.freedesktop.Platform//25.08 \
    org.freedesktop.Sdk//25.08 2>/dev/null || true

# ── Clone shared-modules (one-time) ──

SHARED_MODULES_DIR="$SCRIPT_DIR/shared-modules"
if [ ! -d "$SHARED_MODULES_DIR" ]; then
    echo "==> Cloning flathub/shared-modules..."
    git clone --depth 1 https://github.com/flathub/shared-modules.git "$SHARED_MODULES_DIR"
else
    echo "==> shared-modules already present, skipping clone."
fi

# ── Build the Flutter app ──

echo "==> Building Flutter app..."
cd "$REPO_ROOT"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build linux

# ── Create portable tarball ──

BUNDLE_DIR="build/linux/x64/release/bundle"
echo "==> Creating portable archive from $BUNDLE_DIR..."
touch "$BUNDLE_DIR/PORTABLE"
tar -czf "$REPO_ROOT/Nyrna-Linux-Portable.tar.gz" -C "$BUNDLE_DIR" .

# ── Build the Flatpak ──

echo "==> Building Flatpak..."
cd "$SCRIPT_DIR"

# Clean up any stale rofiles-fuse mounts from a previous interrupted build.
echo "==> Cleaning up any stale FUSE mounts..."
for mount in "$SCRIPT_DIR/.flatpak-builder/rofiles"/rofiles-*; do
    if [ -d "$mount" ]; then
        fusermount3 -uz "$mount" 2>/dev/null || fusermount -uz "$mount" 2>/dev/null || true
        rmdir "$mount" 2>/dev/null || true
    fi
done

flatpak-builder \
    --force-clean \
    --user \
    --install \
    --install-deps-from=flathub \
    "$SCRIPT_DIR/build-dir" \
    "$SCRIPT_DIR/codes.merritt.Nyrna.dev.yml"

echo ""
echo "==> Flatpak built and installed successfully!"
echo "    Run with:  flatpak run codes.merritt.Nyrna"
