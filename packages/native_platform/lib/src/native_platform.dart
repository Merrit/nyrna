import 'dart:io';

import 'active_window.dart';
import 'linux/linux.dart';
import 'native_process.dart';
import 'win32/win32.dart';
import 'window.dart';

/// Interact with the native operating system.
///
/// Abstract class bridges types for specific operating systems.
/// Used by [Linux] and [Win32].
abstract class NativePlatform {
  // Return correct subtype depending on the current operating system.
  factory NativePlatform() {
    if (Platform.isLinux) {
      return Linux();
    } else {
      return Win32();
    }
  }

  /// The index of the currently active virtual desktop.
  Future<int> currentDesktop();

  /// The PID associated with the given [windowId].
  Future<int> windowPid(int windowId);

  /// The process associated with the given [windowId].
  Future<NativeProcess> windowProcess(int windowId);

  /// List of [Window] objects for every visible window with title text.
  ///
  /// Setting [showHidden] to `true` will list windows from every
  /// virtual desktop, as well as some that might be mistakenly cloaked.
  Future<List<Window>> windows({required bool showHidden});

  /// The active, foreground window.
  Future<ActiveWindow> activeWindow();

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();

  /// Minimize the window with the given [windowId].
  Future<bool> minimizeWindow(int windowId);

  /// Restore / unminimize the window with the given [windowId].
  Future<bool> restoreWindow(int windowId);
}
