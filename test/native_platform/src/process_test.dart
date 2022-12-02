import 'dart:io' as io;

import 'package:nyrna/native_platform/native_platform.dart';
import 'package:test/test.dart';

void main() {
  final pid = io.pid; // Dart or Nyrna's own pid.
  late Process process;

  group('Process:', () {
    setUp(() {
      return process = Process(
        executable: 'nyrna',
        pid: pid,
        status: ProcessStatus.normal,
      );
    });

    test('Can instantiate', () {
      expect(process, isA<Process>());
    });

    group('pid', () {
      setUp(() {
        return process = Process(
          executable: 'nyrna',
          pid: pid,
          status: ProcessStatus.normal,
        );
      });

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
        process = Process(
          executable: 'nyrna',
          pid: pid,
          status: ProcessStatus.normal,
        );
        final processRepository = ProcessRepository.init();
        status = await processRepository.getProcessStatus(pid);
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
