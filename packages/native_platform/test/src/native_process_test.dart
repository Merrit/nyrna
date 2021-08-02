import 'dart:io' as io;

import 'package:native_platform/native_platform.dart';
import 'package:native_platform/src/native_process.dart';
import 'package:test/test.dart';

void main() {
  final pid = io.pid; // Dart or Nyrna's own pid.
  NativeProcess? process;

  setUp(() => process = NativeProcess(pid));
  tearDown(() => process = null);

  test('Can instantiate Process', () {
    expect(process, isA<NativeProcess>());
  });

  group('pid', () {
    test('pid is not null', () {
      expect(process!.pid, isA<int>());
    });

    test('pid is not 0', () {
      expect(process!.pid, isNonZero);
    });
  });

  group('executable', () {
    test('executable is a String', () async {
      print('pid: $pid');
      var executable = await process!.executable;
      print('executable name: $executable');
      expect(executable, isA<String>());
    });

    test('executable name is not empty', () async {
      var executable = await process!.executable;
      expect(executable, isNotEmpty);
    });
  });

  group('status', () {
    test('status is a ProcessStatus', () async {
      var status = await process!.status;
      expect(status, isA<ProcessStatus>());
    });

    test('status is not null', () async {
      var status = await process!.status;
      expect(status, isNotNull);
    });

    test('status is normal', () async {
      // Because this is the current process, it really should be..
      var status = await process!.status;
      expect(status, ProcessStatus.normal);
    });
  });
}
