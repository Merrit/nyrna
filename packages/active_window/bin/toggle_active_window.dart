import 'dart:io';

import 'package:active_window/active_window.dart';
import 'package:args/args.dart';
import 'package:native_platform/native_platform.dart';

/// This is a self-contained executable, and should be used as a hotkey
/// on Windows systems by using the included `toggle_active_hotkey.exe`
/// which sits in the system tray and listens for
/// the `Pause` keyboard key to activate. This helper executable is
/// necessary because unlike Linux, where the application can take an
/// argument and start hidden and find the active window, when hidden GUI windows
/// are created on Win32 systems they steal focus from the active application.

/// Message to be displayed if called in terminal.
const _helpText = '''
This Nyrna executable is for Win32 systems to toggle the 
suspend / resume state of the active, foreground window.

This executable should be called by the included hotkey program 
"toggle_active_hotkey.exe" and not manually.
''';

Future<void> main(List<String> args) async {
  final argParser = ArgumentParser();
  argParser.parseArgs(args);

  if (!argParser.shouldToggleActiveWindow) {
    await Logger.log('Not asked to toggle window, exiting.');
    exit(0);
  }

  await toggleActiveWindow(
    shouldLog: argParser.logToFile,
    nativePlatform: NativePlatform(),
  );
}

/// Parse command-line arguments.
class ArgumentParser {
  final _parser = ArgParser(usageLineLength: 80);

  bool logToFile = false;
  bool shouldToggleActiveWindow = false;

  /// Parse received arguments.
  void parseArgs(List<String> args) {
    _parser
      ..addFlag(
        'toggle',
        abbr: 't',
        negatable: false,
        callback: (bool value) => shouldToggleActiveWindow = value,
        help: 'Toggle the suspend / resume state for the active window.',
      )
      ..addFlag(
        'log',
        abbr: 'l',
        negatable: false,
        callback: (bool value) => logToFile = value,
        help: 'Log events to a temporary file for debug purposes.',
      );

    try {
      final result = _parser.parse(args);
      if (result.rest.isNotEmpty) {
        stdout.writeln(_helpText);
        exit(0);
      }
    } on ArgParserException {
      stdout.writeln(_helpText);
      exit(0);
    }
  }
}
