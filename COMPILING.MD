# Compiling Nyrna


## Requirements

Compiling Nyrna requires a working Flutter setup with desktop support.

See https://flutter.dev/desktop for full instructions on setting up Flutter with
desktop support enabled.

### Linux Requirements

- Clang
- CMake
- GTK development headers
- Ninja build
- pkg-config
- libblkid
- liblzma
- Flutter SDK on channel `beta`

### Windows Requirements

- [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/) (not to be confused with Visual Studio Code) with the “Desktop development with C++” workload installed, including all of its default components

<br>

## Building

Run these commands from the root directory of the repo:

1. `flutter clean`
2. `flutter pub get`
3. `flutter build linux` or `flutter build windows`

Note: You must compile on the target operating system.

### Output location

#### Linux

`build/linux/release/bundle` or `build/linux/x64/release/bundle`

#### Windows

`build\windows\runner\Release`