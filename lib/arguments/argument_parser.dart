import 'package:args/args.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/logger/logger.dart';

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
    _parser.addFlag(
      'toggle',
      abbr: 't',
      defaultsTo: false,
    );
    _parser.addFlag(
      'log',
      abbr: 'l',
      defaultsTo: false,
    );
  }

  Future<void> _parse() async {
    // Parse toggle flag.
    ArgResults results;
    try {
      results = _parser.parse(args);
    } on ArgParserException catch (e) {
      print('Unknown argument: $e');
    }
    try {
      final toggle = results.wasParsed('toggle');
      if (toggle) Config.toggle = true;
    } catch (e) {
      print('Error parsing toggle flag: \n$e');
    }
    // Parse log flag.
    bool logger;
    try {
      logger = results.wasParsed('log');
    } catch (e) {
      print('Error parsing logger flag: \n$e');
    }
    if (logger) {
      // Set environment variable.
      Config.log = true;
      // One-time initialization of the logger.
      final logger = Logger.instance;
      await logger.init();
    }
  }
}
