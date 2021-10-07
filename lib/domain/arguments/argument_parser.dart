import 'dart:io';

import 'package:args/args.dart';

/// Parse command-line arguments.
class ArgumentParser {
  final List<String> args;
  final ArgResults _results;

  ArgumentParser(this.args) : _results = _parseArgs(args);

  static final _parser = ArgParser();

  /// Parse received arguments.
  static ArgResults _parseArgs(List<String> args) {
    try {
      return _parser.parse(args);
    } on ArgParserException {
      stdout.writeln("Nyrna doesn't currently accept any arguments.\n"
          '\n'
          'For usage instructions refer to the README.md included with Nyrna, '
          'or see them online at https://nyrna.merritt.codes/usage');
      exit(0);
    }
  }

  bool argWasReceived(String arg) => _results.wasParsed(arg);
}
