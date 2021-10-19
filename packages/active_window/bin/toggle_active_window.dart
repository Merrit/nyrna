import 'dart:io';

import 'package:active_window/active_window.dart';
import 'package:args/args.dart';
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

void parseArgs(List<String> args) {
  final argparser = ArgParser();
  argparser.addFlag(
    'log',
    abbr: 'l',
    defaultsTo: false,
  );
  ArgResults argResults;
  try {
    argResults = argparser.parse(args);
    final gotLog = argResults.wasParsed('log');
    if (gotLog) Logger.shouldLog = true;
  } catch (_) {
    print('Nyrna\'s toggle executable only accepts one argument: --log'
        '\n'
        'Use this for debugging issues, otherwise call this executable '
        'without any arguments from a keyboard hotkey to '
        'suspend / resume the active window.');
    exit(0);
  }
}

Future<void> main(List<String> args) async {
  parseArgs(args);

  Hive.init(Directory.systemTemp.path);

  final nativePlatform = NativePlatform();

  final activeWindow = ActiveWindowHandler(nativePlatform);

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
