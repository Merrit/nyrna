import 'dart:io';
import 'package:nyrna/config.dart';
import 'package:path_provider/path_provider.dart' as p;

/// Log debug messages to a temp file.
class Logger {
  // Logger is a singleton.
  Logger._privateConstructor();
  static final Logger instance = Logger._privateConstructor();

  /// System's temp dir, for example: `/tmp`.
  Directory _tempDir;

  String _tempPath;

  Future<void> init() async {
    _tempDir = await p.getTemporaryDirectory();
    _tempPath = _tempDir.path;
    assert(_tempPath != null);
    _logFile = getLogFile();
    // Check for previous log.
    final previousLog = await _logFile.exists();
    // If a log > 1MB exists, rename it and start a new log.
    if (previousLog) {
      final size = await _logFile.length();
      if (size > 1000000) await _backupLog();
    }
  }

  File _logFile;

  /// Handle to the `nyrna.log` file.
  File getLogFile() {
    if (_logFile != null) return _logFile;
    _logFile = File('$_tempPath/nyrna.log');
    return _logFile;
  }

  Future<void> _backupLog() async {
    await _logFile.rename('$_tempPath/nyrna.log.old');
  }

  /// Write line(s) to the `nyrna.log` file.
  Future<void> log(Object object) async {
    if (Config.log) {
      await _logFile.writeAsString(
        '${DateTime.now()} $object'
        '\n',
        mode: FileMode.append,
      );
    }
  }

  /// Flush the log to ensure it has been written to disk before exiting.
  Future<void> flush(Object object) async {
    if (Config.log) {
      await _logFile.writeAsString('\n${DateTime.now()} $object');
      await _logFile.writeAsString(
        '===== Flush log =====\n',
        mode: FileMode.append,
        flush: true,
      );
    }
  }
}
