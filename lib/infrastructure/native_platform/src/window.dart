import 'dart:io';

import 'linux/linux_window.dart';
import 'win32/win32_window.dart';

/// Represents a visible window on the current desktop.
class Window {
  Window({
    required this.id,
    required this.pid,
    required this.title,
  });

  final _windowControls = WindowControls();

  /// The unique window ID number associated with this window.
  final int id;

  /// The PID of the process associated with this window.
  final int pid;

  /// The title of this window, often shown on the window's 'Title Bar'.
  ///
  /// Can & does change, for example a browser shows the title of the page.
  final String title;

  /// Minimize this window.
  Future<void> minimize() async => await _windowControls.minimize(id);

  /// Restore (un-minimize) this window.
  Future<void> restore() async => await _windowControls.restore(id);
}

/// Provides window actions like [minimize] & [restore].
abstract class WindowControls {
  factory WindowControls() {
    if (Platform.isLinux) {
      return LinuxWindowControls();
    } else {
      return Win32WindowControls();
    }
  }

  /// Minimize the window associated with the given [id].
  Future<void> minimize(int? id);

  /// Restore (un-minimize) the window associated with the given [id].
  Future<void> restore(int? id);
}