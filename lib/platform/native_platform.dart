import 'dart:io';

import 'package:nyrna/platform/linux.dart';
import 'package:nyrna/platform/win32/win32.dart';
import 'package:nyrna/window/window.dart';

/// Interact with the native operating system.
///
/// Abstract class bridges types for specific operating systems.
/// Used by [Linux] and [Win32].
abstract class NativePlatform {
  // Return correct subtype depending on the current operating system.
  factory NativePlatform() {
    switch (Platform.operatingSystem) {
      case 'linux':
        return Linux();
        break;
      case 'windows':
        return Win32();
        break;
      default:
        return null;
        break;
    }
  }

  /// Returns the index of the currently active virtual desktop.
  Future<int> get currentDesktop;

  /// Returns a Map where the keys are the `pid` and the values are [Window]
  /// objects, based on the reported open application windows.
  Future<Map<String, Window>> get windows;

  /// Returns the pid associated with the active window.
  Future<int> get activeWindowPid;

  /// Returns the unique hex id for the active window.
  Future<int> get activeWindowId;

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();
}
