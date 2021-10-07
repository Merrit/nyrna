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

  /// Returns the index of the currently active virtual desktop.
  Future<int> get currentDesktop;

  /// The PID associated with a window.
  Future<int> windowPid(int windowId);

  /// The process associated with a window.
  Future<NativeProcess> windowProcess(int windowId);

  /// List of [Window] objects for every visible window with title text.
  ///
  /// Setting [showHidden] to `true` will list windows from every
  /// virtual desktop, as well as some that might be mistakenly cloaked.
  Future<List<Window>> windows({required bool showHidden});

  Future<NativeActiveWindow> activeWindow();

  /// Returns the pid associated with the active window.
  Future<int> get activeWindowPid;

  /// Returns the unique hex id for the active window.
  Future<int> get activeWindowId;

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();

  Future<bool> minimizeWindow(int windowId);

  Future<bool> restoreWindow(int windowId);
}
