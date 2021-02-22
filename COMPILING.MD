Compiling Nyrna requires a working Flutter setup with desktop support.

For Linux this will mean:

- Clang
- CMake
- GTK development headers
- Ninja build
- pkg-config
- libblkid
- liblzma
- Flutter SDK on channel `dev`

See https://flutter.dev/desktop for full instructions on setting up Flutter with
desktop support enabled.

#### Recommended

Run the build script which will make sure everything is cleaned and ready, and
creates an appropriately named output.

```bash
cd packaging
./build-linux.sh
```

#### Manual

From the root directory of the repo:

```bash
flutter build linux
```
