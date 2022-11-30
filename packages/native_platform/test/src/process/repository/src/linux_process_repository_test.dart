import 'dart:io' show ProcessResult, ProcessSignal;

import 'package:native_platform/src/process/models/process.dart';
import 'package:native_platform/src/process/repository/src/linux_process_repository.dart';
import 'package:native_platform/src/typedefs.dart';
import 'package:test/test.dart';

late KillFunction mockKill;
late RunFunction mockRun;

void main() {
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
        final testPid = 123367;

        RunFunction mockRun = (String executable, List<String> args) async {
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
        final testPid = 155867;

        RunFunction mockRun = (String executable, List<String> args) async {
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
        final testPid = 155867;

        RunFunction mockRun = (String executable, List<String> args) async {
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
        final testPid = 123367;

        RunFunction mockRun = (String executable, List<String> args) async {
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
    });
  });
}
