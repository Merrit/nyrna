import 'dart:io';

import 'package:flutter/foundation.dart';

/// Manages log files.
class LogFileService {
  /// The maximum size of a log file.
  static const int _maxLogFileSize = 2 * 1024 * 1024; // 2MB

  /// The directory where log files are stored.
  final Directory _logDir;

  LogFileService(this._logDir) : _today = _getTodayDate();

  /// Today's date in the format yyyy-mm-dd.
  final String _today;

  /// Get the log file.
  ///
  /// There should be one log file per day, with a maximum of 7 days.
  ///
  /// If a log file we are appending to is larger than 2MB, a new log file will
  /// be created. For example, if today's log file is called 2021-01-01.txt and
  /// it is larger than 2MB, a new log file will be created called
  /// 2021-01-01_2.txt. If the current log file is called 2021-01-01_2.txt and
  /// it is larger than 2MB, a new log file will be created called
  /// 2021-01-01_3.txt.
  ///
  /// If the desired log file is not accessible, an alternative will be used.
  ///
  /// If the log file cannot be created, returns null.
  ///
  /// If appending to a log file, will insert a divider between the old and new
  /// logs.
  Future<File?> getLogFile() async {
    if (!await _logDir.exists()) {
      try {
        await _logDir.create();
      } on Exception catch (e) {
        debugPrint('Could not create log directory: $e');
        return null;
      }
    }

    await _deleteOldLogFiles();
    final String fileName = '$_today.txt';
    File logFile = File('${_logDir.path}${Platform.pathSeparator}$fileName');
    final bool exists = await logFile.exists();

    if (!exists) {
      return _createLogFile(logFile);
    }

    final size = await logFile.length();

    if (size < _maxLogFileSize) {
      await _appendDivider(logFile);
      return logFile;
    }

    final List<File> logFiles = await getAllLogFiles();

    // List all log files that start with the current date.

    final List<File> todayLogFiles = logFiles
        .where((file) => file.path.contains(_today))
        .toList();

    logFile = await _getNumberedLogFile(todayLogFiles);
    return logFile;
  }

  /// Get a list of all log files.
  ///
  /// The list will be sorted from newest to oldest.
  Future<List<File>> getAllLogFiles() async {
    if (!await _logDir.exists()) {
      try {
        await _logDir.create();
      } on Exception catch (e) {
        debugPrint('Could not create log directory: $e');
        return [];
      }
    }

    final List<FileSystemEntity> files = _logDir.listSync();

    final List<File> logFiles = files
        .whereType<File>()
        .where((file) => file.path.endsWith('.txt'))
        .toList();

    logFiles.sort((a, b) => b.path.compareTo(a.path));

    return logFiles;
  }

  /// Append a divider to the log file.
  ///
  /// The divider will be a line of 80 dashes with a newline before and after.
  Future<void> _appendDivider(File logFile) async {
    final dateTime = DateTime.now().toLocal();
    // Current local time, in format of: 2023-08-07 13:52:40
    final currentTime = dateTime.toString().split('.').first;

    final String divider =
        '''

--------------------------------------------------------------------------------

$currentTime

''';

    try {
      await logFile.writeAsString(divider, mode: FileMode.append);
    } on Exception catch (e) {
      debugPrint('Could not append divider to log file: $e');
    }
  }

  /// Create a new log file.
  ///
  /// If the log file cannot be created, returns null.
  Future<File?> _createLogFile(File logFile) async {
    try {
      await logFile.create();
    } on Exception catch (e) {
      debugPrint('Could not create log file: $e');
      return null;
    }

    return logFile;
  }

  /// If there are more than 7 days of logs, delete the oldest log files.
  Future<void> _deleteOldLogFiles() async {
    final List<File> logFiles = await getAllLogFiles()
      // Remove any numbered log files.
      ..removeWhere((file) => file.path.split(Platform.pathSeparator).last.contains('_'));

    if (logFiles.length <= 7) {
      return;
    }

    final List<File> oldLogFiles = logFiles.sublist(7);

    for (final logFile in oldLogFiles) {
      try {
        await logFile.delete();
      } on Exception catch (e) {
        debugPrint('Could not delete old log file: $e');
      }
    }
  }

  /// Get the highest number from a list of numbered log files.
  int _getHighestNumber(List<File> todayLogFiles) {
    if (todayLogFiles.length == 1) {
      return 0;
    }

    // Remove any log files that are not numbered.
    todayLogFiles.removeWhere(
      (file) => file.path.split(Platform.pathSeparator).last.contains('_') == false,
    );

    final int highestNumber = todayLogFiles
        .map((file) => int.parse(file.path.split('_').last.split('.').first))
        .reduce((value, element) => value > element ? value : element);

    return highestNumber;
  }

  /// Get the current numbered log file.
  ///
  /// [todayLogFiles] is a list of existing log files for today.
  ///
  /// The first log file of the day will not have a number, subsequent log files
  /// will have an underscore and a number. For example, 2021-01-01.txt and
  /// 2021-01-01_2.txt.
  ///
  /// Returns the most recent log file that is not at the maximum size.
  ///
  /// If all log files are at the maximum size, creates a new log file.
  Future<File> _getNumberedLogFile(List<File> todayLogFiles) async {
    for (final logFile in todayLogFiles) {
      final size = await logFile.length();

      if (size < _maxLogFileSize) {
        await _appendDivider(logFile);
        return logFile;
      }
    }

    // If all log files are at the maximum size, create a new log file.
    final int highestNumber = _getHighestNumber(todayLogFiles);
    final String newFileName = '${_today}_${highestNumber + 1}.txt';

    final File newLogFile = File('${_logDir.path}${Platform.pathSeparator}$newFileName');

    await newLogFile.create();

    return newLogFile;
  }

  /// Get today's date in the format yyyy-mm-dd.
  static String _getTodayDate() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
