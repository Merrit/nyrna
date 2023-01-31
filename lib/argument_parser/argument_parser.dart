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
  bool? minimize;
  bool toggleActiveWindow = false;
  bool verbose = false;

  /// Singleton instance.
  static late ArgumentParser instance;

  ArgumentParser() {
    instance = this;
  }

  final _parser = ArgParser(usageLineLength: 80);

  /// Parse received arguments.
  void parseArgs(List<String> args) {
    _parser
      ..addFlag(
        'minimize',
        defaultsTo: true,
        callback: (bool value) {
          /// We only want to register when the user calls the negated version of
          /// this flag: `--no-minimize`. Otherwise the [minimize] value will be
          /// null and the UI-set preference can be checked.
          if (value == true) {
            return;
          } else {
            minimize = false;
          }
        },
        help: '''
Used with the `toggle` flag, `no-minimize` instructs Nyrna not to automatically minimize / restore the active window - it will be suspended / resumed only.''',
      )
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
        'verbose',
        abbr: 'v',
        negatable: false,
        callback: (bool value) => verbose = value,
        help: 'Output verbose logs for troubleshooting and debugging.',
      );

    final helpText = '$_helpTextGreeting${_parser.usage}\n\n';

    try {
      final result = _parser.parse(args);
      if (result.rest.isNotEmpty) {
        stdout.writeln(helpText);
        exit(0);
      }
    } on ArgParserException {
      stdout.writeln(helpText);
      exit(0);
    }
  }
}
