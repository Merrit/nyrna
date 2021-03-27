import 'package:args/args.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/logger/log_file.dart';

/// Parse command-line arguments.
///
/// `Toggle` flag available with `-t` or `--toggle`.
///
/// `Logger` flag available with `-l` or `--log`.
///
/// Both options available with `-tl`.
class ArgumentParser {
  ArgumentParser(this.args);

  final List<String> args;

  final _parser = ArgParser();

  Future<void> init() async {
    _setFlags();
    await _parse();
  }

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

  ArgResults _results;

  Future<void> _parse() async {
    _parseArgs();
    _checkToggleFlag();
    await _checkLogFlag();
  }

  /// Parse received arguments.
  void _parseArgs() {
    try {
      _results = _parser.parse(args);
    } on ArgParserException catch (e) {
      print('Unknown argument: $e');
    }
  }

  /// Check if `toggle` flag was received.
  void _checkToggleFlag() {
    final toggle = _results.wasParsed('toggle');
    if (toggle) Config.toggle = true;
  }

  /// Check if `log` flag was received.
  Future<void> _checkLogFlag() async {
    final logger = _results.wasParsed('log');
    if (logger) {
      // Set environment variable.
      Config.log = true;
      // One-time initialization of the logger.
      final logFile = LogFile.instance;
      await logFile.init();
    }
  }
}
