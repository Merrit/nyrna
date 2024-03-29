import 'dart:io' show ProcessResult, ProcessSignal;

import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/native_platform/src/typedefs.dart';
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
    });
  });
}
