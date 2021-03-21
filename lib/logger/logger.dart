import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;

/// Log debug messages to a temp file.
class Logger {
  // Logger is a singleton.
  Logger._privateConstructor();
  static final Logger instance = Logger._privateConstructor();

  /// System's temp dir, for example: `/tmp`.
  Directory _tempDir;

  /// Absolute path to `nyrna.log`.
  File _logFile;

  Future<void> init() async {
    _tempDir = await p.getTemporaryDirectory();
    _logFile = File('${_tempDir.path}/nyrna.log');
    // Clean up previous log, if it exists.
    final previousLog = await _logFile.exists();
    if (previousLog) await _logFile.delete();
  }

  /// Write line(s) to the `nyrna.log` file.
  Future<void> log(Object object) async {
    await _logFile.writeAsString(
      '${DateTime.now()} $object'
      '\n',
      mode: FileMode.append,
    );
  }

  /// Flush the log to ensure it has been written to disk before exiting.
  Future<void> flush(Object object) async {
    await _logFile.writeAsString(
      '\n'
      '===== Flush log ====='
      '\n'
      '${DateTime.now()} $object'
      '\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
