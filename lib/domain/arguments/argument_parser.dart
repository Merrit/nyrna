import 'dart:io';

import 'package:args/args.dart';
import 'package:nyrna/infrastructure/logger/log_file.dart';

/// Parse command-line arguments.
///
/// `Toggle` flag available with `-t` or `--toggle`.
///
/// `Logger` flag available with `-l` or `--log`.
///
/// Both options available with `-tl`.
class ArgumentParser {
  ArgumentParser(this.args) {
    _setFlags();
  }

  final List<String> args;

  final _parser = ArgParser();

  void _setFlags() {
    // Toggle flag means Nyrna should toggle the suspend / resume state of the
    // active application and then exit. Needed as a workaround since Flutter
    // doesn't currently support a global hotkey. Not reliable if Nyrna is
    // already running.
    _parser.addFlag(
      'toggle',
      abbr: 't',
      defaultsTo: false,
    );
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

  /// Check if `toggle` flag was received.
  ///
  /// If toggle is true => toggle suspend for active window,
  /// do not load GUI.
  bool get toggleFlagged => _results.wasParsed('toggle');

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
