import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/process.dart';

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
    test('executable is a String', () {
      expect(process.executable, isA<String>());
    });

    test('executable name is not empty', () {
      expect(process.executable, isNotEmpty);
    });
  });

  group('status', () {
    test('status is a String', () {
      expect(process.status, isA<String>());
    });

    test('status is not empty', () {
      expect(process.status, isNotEmpty);
    });

    test('status is normal', () {
      // Because this is the current process, it really should be..
      expect(process.status, 'normal');
    });
  });
}
