import 'dart:io';

import 'package:nyrna/platform/linux.dart';
import 'package:nyrna/platform/win32.dart';
import 'package:nyrna/window/window.dart';

class NativePlatform {
  NativePlatform _platform;

  NativePlatform() {
    switch (Platform.operatingSystem) {
      case 'linux':
        _platform = Linux();
        break;
      case 'windows':
        _platform = Win32();
        break;
      default:
        break;
    }
  }

  /// Returns the index of the currently active virtual desktop.
  Future<int> get currentDesktop async => await _platform.currentDesktop;

  /// Returns a Map where the keys are the `pid` and the values are [Window]
  /// objects, based on the reported open application windows.
  Future<Map<String, Window>> get windows async => await _platform.windows;

  /// Returns the pid associated with the active window.
  Future<int> get activeWindowPid => _platform.activeWindowPid;

  /// Returns the unique hex id for the active window.
  Future<int> get activeWindowId => _platform.activeWindowId;

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies() async => await _platform.checkDependencies();
}
