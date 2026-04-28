import 'dart:io';

import 'package:nyrna/logs/log_file_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late LogFileService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('nyrna_log_test_');
    service = LogFileService(tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LogFileService - file creation:', () {
    test('getLogFile() returns a File with today\'s date in the name', () async {
      final file = await service.getLogFile();

      expect(file, isNotNull);
      final today = _getTodayDate();
      expect(file!.path, contains(today));
      expect(file.path, endsWith('.txt'));
    });

    test('getLogFile() creates the log directory if it does not exist', () async {
      final nestedDir = Directory('${tempDir.path}${Platform.pathSeparator}nested_logs');
      final nestedService = LogFileService(nestedDir);

      expect(nestedDir.existsSync(), isFalse);

      final file = await nestedService.getLogFile();

      expect(nestedDir.existsSync(), isTrue);
      expect(file, isNotNull);
    });

    test('getLogFile() returns a file that exists on disk', () async {
      final file = await service.getLogFile();

      expect(file, isNotNull);
      expect(file!.existsSync(), isTrue);
    });
  });

  group('LogFileService - getAllLogFiles():', () {
    test('returns only .txt files', () async {
      // Create a mix of txt and non-txt files.
      File('${tempDir.path}${Platform.pathSeparator}2025-01-01.txt').createSync();
      File('${tempDir.path}${Platform.pathSeparator}2025-01-02.txt').createSync();
      File('${tempDir.path}${Platform.pathSeparator}notes.md').createSync();
      File('${tempDir.path}${Platform.pathSeparator}data.json').createSync();

      final files = await service.getAllLogFiles();

      expect(files.every((f) => f.path.endsWith('.txt')), isTrue);
      expect(files.length, 2);
    });

    test('returns files sorted newest to oldest', () async {
      File('${tempDir.path}${Platform.pathSeparator}2025-01-01.txt').createSync();
      File('${tempDir.path}${Platform.pathSeparator}2025-01-03.txt').createSync();
      File('${tempDir.path}${Platform.pathSeparator}2025-01-02.txt').createSync();

      final files = await service.getAllLogFiles();

      expect(files.length, 3);
      expect(files[0].path, contains('2025-01-03'));
      expect(files[1].path, contains('2025-01-02'));
      expect(files[2].path, contains('2025-01-01'));
    });

    test('returns empty list when directory has no .txt files', () async {
      File('${tempDir.path}${Platform.pathSeparator}readme.md').createSync();

      final files = await service.getAllLogFiles();

      expect(files, isEmpty);
    });
  });

  group('LogFileService - rotation and cleanup:', () {
    test('getLogFile() appends a divider when an existing file is reused', () async {
      final today = _getTodayDate();
      final existingFile = File('${tempDir.path}${Platform.pathSeparator}$today.txt')
        ..createSync()
        ..writeAsStringSync('initial log content');

      final file = await service.getLogFile();

      expect(file, isNotNull);
      expect(file!.path, existingFile.path);
      final content = await file.readAsString();
      expect(content, contains('---'));
    });

    test(
      'getLogFile() returns a new numbered file when today\'s file exceeds 2 MB',
      () async {
        final today = _getTodayDate();
        final bigContent = 'x' * (2 * 1024 * 1024 + 1); // just over 2 MB
        File('${tempDir.path}${Platform.pathSeparator}$today.txt')
          ..createSync()
          ..writeAsStringSync(bigContent);

        final file = await service.getLogFile();

        expect(file, isNotNull);
        // When only the un-numbered file exists and is full, the service creates
        // the first numbered file (_1.txt). Subsequent overflows increment the
        // number further.
        expect(file!.path, contains('${today}_'));
        expect(file.path, endsWith('.txt'));
      },
    );

    test('getLogFile() deletes oldest file when more than 7 log files exist', () async {
      // Create 8 files with past dates, sorted with the oldest first in naming.
      final oldestFileName = '2020-01-01.txt';
      for (var i = 1; i <= 8; i++) {
        File('${tempDir.path}${Platform.pathSeparator}2020-01-0$i.txt').createSync();
      }

      // getLogFile() triggers _deleteOldLogFiles() before creating today's file.
      await service.getLogFile();

      final oldestFile = File('${tempDir.path}${Platform.pathSeparator}$oldestFileName');
      expect(
        oldestFile.existsSync(),
        isFalse,
        reason: 'oldest file should have been deleted',
      );
    });

    test('getLogFile() does not delete files when 7 or fewer log files exist', () async {
      for (var i = 1; i <= 7; i++) {
        File('${tempDir.path}${Platform.pathSeparator}2020-01-0$i.txt').createSync();
      }

      await service.getLogFile();

      // All 7 pre-existing files should survive.
      for (var i = 1; i <= 7; i++) {
        final file = File('${tempDir.path}${Platform.pathSeparator}2020-01-0$i.txt');
        expect(file.existsSync(), isTrue);
      }
    });
  });
}

String _getTodayDate() {
  final now = DateTime.now();
  return '${now.year}-${now.month}-${now.day}';
}
