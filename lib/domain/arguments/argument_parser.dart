import 'dart:io';

import 'package:args/args.dart';

/// Message to be displayed if Nyrna is called with an unknown argument.
const _helpTextGreeting = '''
Nyrna - Suspend games and applications.


Run Nyrna without any arguments to launch the GUI.

Supported arguments:

''';

/// Parse command-line arguments.
class ArgumentParser {
  bool logToFile = false;
  bool toggleActiveWindow = false;

  final _parser = ArgParser(usageLineLength: 80);

  /// Parse received arguments.
  void parseArgs(List<String> args) {
    _parser
      ..addFlag(
        'toggle',
        abbr: 't',
        negatable: false,
        callback: (bool value) => toggleActiveWindow = value,
        help: 'Toggle the suspend / resume state for the active window. \n'
            '❗Please note this will immediately suspend the active window, and '
            'is intended to be used with a hotkey - be sure not to run this '
            'from a terminal and accidentally suspend your terminal! ❗',
      )
      ..addFlag(
        'log',
        abbr: 'l',
        negatable: false,
        callback: (bool value) => logToFile = value,
        help: 'Log events to a temporary file for debug purposes.',
      );

    final _helpText = _helpTextGreeting + _parser.usage + '\n\n';

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
