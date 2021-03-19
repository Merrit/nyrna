import 'dart:io';

import 'package:win32/win32.dart';

///
abstract class WindowControls {
  Future<void> minimize(int id);

  Future<void> restore(int id);
}

class WindowControlsProvider {
  static WindowControls getNativeControls() {
    WindowControls _controls;
    switch (Platform.operatingSystem) {
      case 'linux':
        _controls = _LinuxWindowControls();
        break;
      case 'windows':
        _controls = _Win32WindowControls();
        break;
      default:
        break;
    }
    return _controls;
  }
}

///
class _LinuxWindowControls implements WindowControls {
  @override
  Future<void> minimize(int id) async {
    await Process.run(
      'xdotool',
      ['windowminimize', '$id', '--sync'],
    );
  }

  @override
  Future<void> restore(int id) async {
    await Process.run(
      'xdotool',
      ['windowactivate', '$id', '--sync'],
    );
  }
}

class _Win32WindowControls implements WindowControls {
  @override
  Future<void> minimize(int id) async => ShowWindow(id, SW_FORCEMINIMIZE);

  @override
  Future<void> restore(int id) async => ShowWindow(id, SW_RESTORE);
}
