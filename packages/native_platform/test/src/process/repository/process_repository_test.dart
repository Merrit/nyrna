import 'dart:io';

import 'package:native_platform/native_platform.dart';
import 'package:test/test.dart';

void main() {
  group('ProcessRepository:', () {
    test('can be instantiated', () {
      final processRepository = ProcessRepository.init();
      expect(processRepository, isA<ProcessRepository>());
    });

    test('returns correct implementation for operating system', () {
      final processRepository = ProcessRepository.init();
      final expectedImplementation = (Platform.isLinux) //
          ? LinuxProcessRepository
          : Win32ProcessRepository;
      expect(processRepository.runtimeType, expectedImplementation);
    });
  });
}
