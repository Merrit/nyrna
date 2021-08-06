import 'dart:io';

import 'package:active_window/active_window.dart';
import 'package:hive/hive.dart';
import 'package:native_platform/native_platform.dart';

/// The portion of Nyrna that will act as a toggle to
/// suspend / resume the active, foreground window.
///
/// It is a self-contained executable, and should be bound to a hotkey
/// using the operating system's default methods on Linux, or by using
/// the included `toggle_active_hotkey.exe` on Windows which sits in the
/// system tray and listens for the `Pause` keyboard key to activate.
///
/// When the hotkey launches the executable it will:
/// - Find the active, foreground window
/// - Minimize the window
/// - Suspend the process that owns the window
/// - Save the PID of said process & window id to a file
///
/// On subsequent launch when the file with a saved PID is found:
/// - Resume the suspended process
/// - Restore / unminimize the associated window
/// - Delete the file containing the PID & window id so next call will suspend.

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    if (arguments[0] == 'log') Logger.shouldLog = true;
  }

  Hive.init(Directory.systemTemp.path);

  final nativePlatform = NativePlatform();

  final activeWindow = ActiveWindow(nativePlatform);

  final savedPid = await activeWindow.savedPid();

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) await Logger.log('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) await Logger.log('Failed to suspend successfully.');
  }

  await Hive.close();
}
