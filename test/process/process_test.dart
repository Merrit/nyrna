import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/process/process.dart';

// ignore_for_file: unused_local_variable

void main() {
  var pid = io.pid; // The current process' pid.
  Process process;

  setUp(() => process = Process(pid));
  tearDown(() => process = null);

  test('Can instantiate Process', () {
    expect(process, isA<Process>());
  });

  group('pid', () {
    test('pid is not null', () {
      expect(process.pid, isA<int>());
    });

    test('pid is not 0', () {
      expect(process.pid, isNonZero);
    });
  });

  group('executable', () {
    test('executable is a String', () async {
      var executable = await process.executable;
      expect(executable, isA<String>());
    });

    test('executable name is not empty', () async {
      var executable = await process.executable;
      expect(executable, isNotEmpty);
    });
  });

  group('status', () {
    test('status is a String', () async {
      var status = await process.status;
      expect(status, isA<String>());
    });

    test('status is not empty', () async {
      var status = await process.status;
      expect(status, isNotEmpty);
    });

    test('status is normal', () async {
      // Because this is the current process, it really should be..
      var status = await process.status;
      expect(status, 'normal');
    });
  });
}
