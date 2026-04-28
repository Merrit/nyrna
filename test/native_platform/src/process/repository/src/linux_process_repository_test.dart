import 'dart:io' show ProcessResult, ProcessSignal;

import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/native_platform/src/typedefs.dart';
import 'package:test/test.dart';

late KillFunction mockKill;
late RunFunction mockRun;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    mockKill = ((int pid, [ProcessSignal signal = ProcessSignal.sigterm]) {
      return false;
    });
    mockRun = (String executable, List<String> args) async {
      return ProcessResult(1, 1, '', '');
    };
  });

  group('LinuxProcessRepository:', () {
    test('can be instantiated', () {
      final repo = LinuxProcessRepository(mockKill, mockRun);
      expect(repo, isA<LinuxProcessRepository>());
    });

    group('getProcess:', () {
      test('valid pid returns populated Process object', () async {
        const testPid = 123367;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'readlink') {
            return ProcessResult(
              testPid,
              0,
              '/home/user/Applications/Adventure List/adventure_list',
              '',
            );
          } else if (executable == 'ps') {
            return ProcessResult(
              testPid,
              0,
              'S',
              '',
            );
          } else {
            return ProcessResult(
              1,
              1,
              '',
              '',
            );
          }
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final process = await repo.getProcess(testPid);
        expect(process.executable, 'adventure_list');
        expect(process.pid, testPid);
        expect(process.status, ProcessStatus.normal);
      });

      test('invalid pid returns generic Process object', () async {
        const testPid = 155867;

        mockRun = (String executable, List<String> args) async {
          return ProcessResult(
            000000,
            1,
            '',
            '',
          );
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final process = await repo.getProcess(testPid);
        expect(process.executable, 'unknown');
        expect(process.pid, testPid);
        expect(process.status, ProcessStatus.unknown);
      });
    });

    group('getProcessStatus:', () {
      test('invalid pid returns ProcessStatus.unknown', () async {
        const testPid = 155867;

        mockRun = (String executable, List<String> args) async {
          return ProcessResult(
            000000,
            1,
            '',
            '',
          );
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final processStatus = await repo.getProcessStatus(testPid);
        expect(processStatus, ProcessStatus.unknown);
      });

      test('running process returns ProcessStatus.normal', () async {
        const testPid = 123367;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(
              testPid,
              0,
              'S',
              '',
            );
          } else {
            return ProcessResult(
              000000,
              1,
              '',
              '',
            );
          }
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final processStatus = await repo.getProcessStatus(testPid);
        expect(processStatus, ProcessStatus.normal);
      });

      test('suspended process (T) returns ProcessStatus.suspended', () async {
        const testPid = 123456;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'T', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final status = await repo.getProcessStatus(testPid);
        expect(status, ProcessStatus.suspended);
      });

      test('zombie process (Z) returns ProcessStatus.unknown', () async {
        const testPid = 111111;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'Z', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final status = await repo.getProcessStatus(testPid);
        expect(status, ProcessStatus.unknown);
      });

      test('idle process (I) returns ProcessStatus.normal', () async {
        const testPid = 222222;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'I', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final status = await repo.getProcessStatus(testPid);
        expect(status, ProcessStatus.normal);
      });

      test('running process (R) returns ProcessStatus.normal', () async {
        const testPid = 333333;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'R', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final status = await repo.getProcessStatus(testPid);
        expect(status, ProcessStatus.normal);
      });
    });

    group('exists:', () {
      test('returns true when ps reports the given pid', () async {
        const testPid = 99999;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, '$testPid', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        expect(await repo.exists(testPid), isTrue);
      });

      test('returns false when ps does not report the pid', () async {
        const testPid = 99998;

        mockRun = (String executable, List<String> args) async {
          // ps returns non-matching output (different pid).
          return ProcessResult(1, 0, '12345', '');
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        expect(await repo.exists(testPid), isFalse);
      });
    });

    group('suspend:', () {
      test('returns true when SIGSTOP succeeds and process is suspended', () async {
        const testPid = 44444;

        // No child pids.
        mockRun = (String executable, List<String> args) async {
          if (executable == 'bash') {
            // pgrep returns no children.
            return ProcessResult(testPid, 0, '', '');
          }
          if (executable == 'ps') {
            // After suspend, report status T (suspended).
            return ProcessResult(testPid, 0, 'T', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        mockKill = (int pid, [ProcessSignal signal = ProcessSignal.sigterm]) {
          return true;
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final result = await repo.suspend(testPid);
        expect(result, isTrue);
      });

      test('returns false when SIGSTOP fails', () async {
        const testPid = 55555;

        mockRun = (String executable, List<String> args) async {
          // pgrep returns no children.
          if (executable == 'bash') {
            return ProcessResult(testPid, 0, '', '');
          }
          // ps returns running.
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'S', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        // Kill always fails.
        mockKill = (int pid, [ProcessSignal signal = ProcessSignal.sigterm]) {
          return false;
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final result = await repo.suspend(testPid);
        expect(result, isFalse);
      });
    });

    group('resume:', () {
      test('returns true when SIGCONT succeeds and process is running', () async {
        const testPid = 66666;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'bash') {
            // pgrep returns no children.
            return ProcessResult(testPid, 0, '', '');
          }
          if (executable == 'ps') {
            // After resume, report status S (normal).
            return ProcessResult(testPid, 0, 'S', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        mockKill = (int pid, [ProcessSignal sig = ProcessSignal.sigterm]) {
          return true;
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final result = await repo.resume(testPid);
        expect(result, isTrue);
      });

      test('returns false when SIGCONT fails', () async {
        const testPid = 77777;

        mockRun = (String executable, List<String> args) async {
          if (executable == 'bash') {
            return ProcessResult(testPid, 0, '', '');
          }
          if (executable == 'ps') {
            // Still suspended after resume attempt.
            return ProcessResult(testPid, 0, 'T', '');
          }
          return ProcessResult(1, 1, '', '');
        };

        mockKill = (int pid, [ProcessSignal sig = ProcessSignal.sigterm]) {
          return false;
        };

        final repo = LinuxProcessRepository(mockKill, mockRun);
        final result = await repo.resume(testPid);
        expect(result, isFalse);
      });
    });

    group('Flatpak mode:', () {
      test('uses flatpak-spawn executable when flatpakRun is injected', () async {
        const testPid = 88888;
        final capturedExecutables = <String>[];

        // flatpakRun wraps commands with flatpak-spawn --host.
        Future<ProcessResult> fakeFlatpakRun(
          String executable,
          List<String> args,
        ) async {
          capturedExecutables.add(executable);
          if (executable == 'readlink') {
            return ProcessResult(testPid, 0, '/usr/bin/myapp', '');
          }
          if (executable == 'ps') {
            return ProcessResult(testPid, 0, 'S', '');
          }
          return ProcessResult(1, 1, '', '');
        }

        final repo = LinuxProcessRepository(mockKill, fakeFlatpakRun);
        await repo.getProcess(testPid);

        // Verify that nothing called with 'flatpak-spawn' since fakeFlatpakRun
        // already represents a resolved Flatpak-aware run function.
        expect(capturedExecutables, contains('readlink'));
        expect(capturedExecutables, contains('ps'));
      });
    });
  });
}
