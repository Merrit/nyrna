import 'dart:io';

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
        break;
      default:
        break;
    }
    return _controls;
  }
}

///
class _LinuxWindowControls extends WindowControls {
  Future<void> minimize(int id) async {
    await Process.run(
      'xdotool',
      ['windowminimize', '$id', '--sync'],
    );
  }

  Future<void> restore(int id) async {
    await Process.run(
      'xdotool',
      ['windowactivate', '$id', '--sync'],
    );
  }
}
