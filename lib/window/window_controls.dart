import 'dart:io';

import 'package:win32/win32.dart';

/// Provides window actions like [minimize] & [restore].
abstract class WindowControls {
  factory WindowControls() {
    if (Platform.isLinux) {
      return _LinuxWindowControls();
    } else {
      return _Win32WindowControls();
    }
  }

  /// Minimize the window associated with the given [id].
  Future<void> minimize(int? id);

  /// Restore (un-minimize) the window associated with the given [id].
  Future<void> restore(int? id);
}

/// Linux specific window controls using `xdotool`.
class _LinuxWindowControls implements WindowControls {
  @override
  Future<void> minimize(int? id) async {
    await Process.run(
      'xdotool',
      ['windowminimize', '$id', '--sync'],
    );
  }

  @override
  Future<void> restore(int? id) async {
    await Process.run(
      'xdotool',
      ['windowactivate', '$id', '--sync'],
    );
  }
}

/// Win32 specific window controls using the win32 API.
class _Win32WindowControls implements WindowControls {
  @override
  Future<void> minimize(int? id) async => ShowWindow(id!, SW_FORCEMINIMIZE);

  @override
  Future<void> restore(int? id) async => ShowWindow(id!, SW_RESTORE);
}
