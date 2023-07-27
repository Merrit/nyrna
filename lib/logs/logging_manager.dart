import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Globally available instance available for easy logging.
late Logger log;

/// Manages logging for the app.
class LoggingManager {
  /// The file to which logs are saved.
  final File _logFile;

  /// Whether verbose logging is enabled.
  final bool verbose;

  /// Singleton instance for easy access.
  static late LoggingManager instance;

  LoggingManager._(
    this._logFile, {
    required this.verbose,
  }) {
    instance = this;
  }

  static Future<LoggingManager> initialize({bool verbose = false}) async {
    final testing = Platform.environment.containsKey('FLUTTER_TEST');
    if (testing) {
      // Set the logger to a dummy logger during unit tests.
      log = Logger(level: Level.off);
      return LoggingManager._(File(''), verbose: verbose);
    }

    final dataDir = await getApplicationSupportDirectory();
    final logFile = File('${dataDir.path}${Platform.pathSeparator}log.txt');
    if (await logFile.exists()) await logFile.delete();
    await logFile.create();

    final List<LogOutput> outputs = [
      ConsoleOutput(),
      FileOutput(file: logFile),
    ];

    log = Logger(
      filter: ProductionFilter(),
      level: (verbose) ? Level.trace : Level.warning,
      output: MultiOutput(outputs),
      // Colors false because it outputs ugly escape characters to log file.
      printer: PrefixPrinter(PrettyPrinter(colors: false)),
    );

    log.i('Logger initialized.');

    return LoggingManager._(
      logFile,
      verbose: verbose,
    );
  }

  /// Read the logs from this run from the log file.
  Future<String> getLogs() async => await _logFile.readAsString();

  /// Close the logger and release resources.
  void close() => log.close();
}
