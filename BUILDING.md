# Building Nyrna


## Requirements

1. Requires a working instance of [Flutter](https://docs.flutter.dev/get-started/install).

2. Requires `libappindicator` and `keybinder`.
    
    Fedora:

    ```
    sudo dnf install libappindicator-gtk3 libappindicator-gtk3-devel keybinder keybinder3 keybinder3-devel
    ```

    Ubuntu:

    ```
    sudo apt-get install appindicator3-0.1 libappindicator3-dev keybinder-3.0
    ```


## Build

Run these commands from the root directory of the repo:

1. `flutter clean`
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `flutter build linux` or `flutter build windows`


Compiled app location:

Linux: `build/linux/x64/release/bundle`

Windows: `build\windows\runner\Release`
