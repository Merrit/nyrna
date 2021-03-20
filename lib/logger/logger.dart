import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;

/// Log debug messages to a temp file.
class Logger {
  // Logger is a singleton.
  Logger._privateConstructor();
  static final Logger instance = Logger._privateConstructor();

  Directory _tempDir;
  File _logFile;

  Future<void> init() async {
    _tempDir = await p.getTemporaryDirectory();
    _logFile = File('${_tempDir.path}/nyrna.log');
    final previousLog = await _logFile.exists();
    if (previousLog) await _logFile.delete();
  }

  Future<void> log(Object object) async {
    await _logFile.writeAsString(
      '${DateTime.now()} $object'
      '\n',
      mode: FileMode.append,
    );
  }

  // Call flush before exiting Nyrna to ensure log is written to disk.
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
