import 'dart:io';

import 'package:args/args.dart';
import 'package:nyrna/infrastructure/logger/log_file.dart';

/// Parse command-line arguments.
///
/// `Logger` flag available with `-l` or `--log`.
class ArgumentParser {
  ArgumentParser(this.args) {
    _setFlags();
  }

  final List<String> args;

  final _parser = ArgParser();

  void _setFlags() {
    // Log flag is to enable conditional use of the Logger() class for debug.
    _parser.addFlag(
      'log',
      abbr: 'l',
      defaultsTo: false,
    );
  }

  late ArgResults _results;

  Future<void> parse() async {
    _parseArgs();
    await _checkLogFlag();
  }

  /// Parse received arguments.
  void _parseArgs() {
    try {
      _results = _parser.parse(args);
    } on ArgParserException catch (e) {
      print('Unknown argument: $e');
      exit(1);
    }
  }

  static bool _logToFile = false;

  static bool get logToFile => _logToFile;

  /// Check if `log` flag was received.
  Future<void> _checkLogFlag() async {
    final flagReceived = _results.wasParsed('log');
    if (flagReceived) {
      _logToFile = true;
      // One-time initialization of the logger.
      await LogFile.instance.init();
    }
  }
}
