import 'dart:collection';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:nyrna/config.dart';
import 'package:path_provider/path_provider.dart' as p;

/// Log debug messages to a temp file.
///
/// Necessary for the `Toggle` functionality since it won't have
/// a GUI nor console to print logs to.
class LogFile {
  // LogFile is a singleton.
  LogFile._privateConstructor();
  static final LogFile instance = LogFile._privateConstructor();

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

  /// A running list of the log messages so they can be referenced later.
  static final logs = Queue<LogRecord>();

  /// Flush the log to ensure it has been written to disk before exiting.
  Future<void> write() async {
    if (Config.log) {
      await _logFile.writeAsString(
        logs.toString(),
        mode: FileMode.append,
        flush: true,
      );
    }
  }
}
