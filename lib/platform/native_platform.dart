import 'dart:io';

import 'package:nyrna/platform/linux.dart';
import 'package:nyrna/window/window.dart';

class NativePlatform {
  NativePlatform _platform;

  NativePlatform() {
    switch (Platform.operatingSystem) {
      case 'linux':
        _platform = Linux();
        break;
      case 'windows':
        // _platform = Windows();
        break;
      default:
        break;
    }
  }

  /// Returns the index of the currently active virtual desktop.
  Future<int> get currentDesktop async => await _platform.currentDesktop;

  /// Returns a list of [Window] objects based on the reported
  /// open application windows.
  Future<Map<String, Window>> get windows async => await _platform.windows;

  Future<int> get activeWindowPid => _platform.activeWindowPid;

  /// Unique hex id for the active window.
  Future<int> get activeWindowId => _platform.activeWindowId;

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies() async => await _platform.checkDependencies();
}
