import 'dart:io' as io;

import 'linux/flatpak.dart';
import 'linux/linux.dart';
import 'win32/win32.dart';
import 'window.dart';

/// Interact with the native operating system.
///
/// Abstract class bridges types for specific operating systems.
/// Used by [Linux] and [Win32].
abstract class NativePlatform {
  // Return correct subtype depending on the current operating system.
  factory NativePlatform() {
    if (io.Platform.isLinux) {
      final runFunction = (runningInFlatpak) ? flatpakRun : io.Process.run;
      return Linux(runFunction);
    } else {
      return Win32();
    }
  }

  /// The index of the currently active virtual desktop.
  Future<int> currentDesktop();

  /// List of [Window] objects for every visible window with title text.
  ///
  /// Setting [showHidden] to `true` will list windows from every
  /// virtual desktop, as well as some that might be mistakenly cloaked.
  Future<List<Window>> windows({bool showHidden});

  /// The active, foreground window.
  Future<Window> activeWindow();

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();

  /// Minimize the window with the given [windowId].
  Future<bool> minimizeWindow(int windowId);

  /// Restore / unminimize the window with the given [windowId].
  Future<bool> restoreWindow(int windowId);
}
