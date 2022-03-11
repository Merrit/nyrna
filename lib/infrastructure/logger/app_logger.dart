import 'package:logging/logging.dart';

import 'log_file.dart';

class AppLogger {
  final _log = Logger('AppLogger');

  /// Print log messages & add them to a Queue so they can be referenced, for
  /// example from the [LogPage].
  void initialize() {
    final logQueue = LogFile.logs;
    Logger.root.onRecord.listen((record) {
      var msg = '${record.level.name}: ${record.time}: '
          '${record.loggerName}: ${record.message}';
      if (record.error != null) msg += '\nError: ${record.error}';
      _log.info(msg);
      logQueue.addLast(record);
      // In case the log grows too crazy, prune for sanity.
      while (logQueue.length > 100) {
        logQueue.removeFirst();
      }
    });
  }
}
