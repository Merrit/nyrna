import 'dart:io' as io;

import 'package:native_platform/native_platform.dart';
import 'package:test/test.dart';

void main() {
  final pid = io.pid; // Dart or Nyrna's own pid.
  late Process process;

  group('Process:', () {
    setUp(() => process = Process(executable: 'nyrna', pid: pid));

    test('Can instantiate', () {
      expect(process, isA<Process>());
    });

    group('pid', () {
      setUp(() => process = Process(executable: 'nyrna', pid: pid));

      test('is not null', () {
        expect(process.pid, isA<int>());
      });

      test('is not 0', () {
        expect(process.pid, isNonZero);
      });
    });

    group('status', () {
      late ProcessStatus status;

      setUp(() async {
        process = Process(executable: 'nyrna', pid: pid);
        status = await process.refreshStatus();
      });

      test('is a ProcessStatus', () {
        expect(status, isA<ProcessStatus>());
      });

      test('is not null', () {
        expect(status, isNotNull);
      });

      test('is normal', () {
        // Because this is the current process, it really should be..
        expect(status, ProcessStatus.normal);
      });
    });
  });
}
