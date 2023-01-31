import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/active_window/active_window.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/main.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:test/test.dart';

const kActiveWindowStorageArea = 'activeWindow';

class MockArgParser extends Mock implements ArgumentParser {}

class MockNativePlatform extends Mock implements NativePlatform {}

class MockProcessRepository extends Mock implements ProcessRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

const testProcess = Process(
  executable: 'code-insiders',
  pid: 45686,
  status: ProcessStatus.normal,
);

const testWindow = Window(
  id: 130023427,
  process: testProcess,
  title: 'Untitled-2 - Visual Studio Code - Insiders',
);

void main() {
  late ArgumentParser argParser;
  late NativePlatform nativePlatform;
  late ProcessRepository processRepository;
  late StorageRepository storageRepository;

  late ActiveWindow activeWindow;

  setUpAll(() async {
    argParser = MockArgParser();
    ArgumentParser.instance = argParser;
    when(() => argParser.minimize).thenReturn(null);

    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    nativePlatform = MockNativePlatform();
    processRepository = MockProcessRepository();
    storageRepository = MockStorageRepository();

    // Setup initial dummy responses for mocks.

    // NativePlatform
    when(() => nativePlatform.activeWindow())
        .thenAnswer((_) async => testWindow);
    when(() => nativePlatform.minimizeWindow(any()))
        .thenAnswer((_) async => true);
    when(() => nativePlatform.restoreWindow(any()))
        .thenAnswer((_) async => true);

    // ProcessRepository
    when(() => processRepository.suspend(any())).thenAnswer((_) async => true);

    // StorageRepository
    when(() => storageRepository.deleteValue(
          any(),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async {});
    when(() => storageRepository.getValue(
          any(),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async => null);
    when(() => storageRepository.saveValue(
          key: any(named: 'key'),
          value: any(named: 'value'),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async {});
    when(() => storageRepository.close()).thenAnswer((_) async {});

    activeWindow = ActiveWindow(
      nativePlatform,
      processRepository,
      storageRepository,
    );
  });

  group('ActiveWindow:', () {
    test('suspends normal window', () async {
      final successful = await activeWindow.toggle();
      expect(successful, true);
      verify(() => processRepository.suspend(testWindow.process.pid)).called(1);
      verify(() => storageRepository.saveValue(
            key: 'pid',
            value: testWindow.process.pid,
            storageArea: kActiveWindowStorageArea,
          )).called(1);
      verify(() => storageRepository.saveValue(
            key: 'windowId',
            value: testWindow.id,
            storageArea: kActiveWindowStorageArea,
          )).called(1);
    });

    test('explorer.exe executable aborts on Win32', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      when(() => nativePlatform.activeWindow())
          .thenAnswer((_) async => testWindow.copyWith(
                process: testProcess.copyWith(executable: 'explorer.exe'),
              ));
      final successful = await activeWindow.toggle();
      expect(successful, false);
      verifyNever(() => processRepository.suspend(any()));
      // Restore global platform variable.
      debugDefaultTargetPlatformOverride = null;
    });

    test('suspend failure returns false', () async {
      when(() => processRepository.suspend(any()))
          .thenAnswer((_) async => false);
      final successful = await activeWindow.toggle();
      expect(successful, false);
    });

    group('minimizing & restoring:', () {
      test('no flag or preference defaults to minimizing', () async {
        expect(argParser.minimize, null);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verify(() => nativePlatform.minimizeWindow(any())).called(1);
      });

      test('no flag & preference=false does not minimize', () async {
        when(() => storageRepository.getValue('minimizeWindows'))
            .thenAnswer((_) async => false);
        expect(argParser.minimize, null);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(() => nativePlatform.minimizeWindow(any()));
      });

      test('no-minimize flag received & no preference does not minimize',
          () async {
        when(() => argParser.minimize).thenReturn(false);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(() => nativePlatform.minimizeWindow(any()));
      });

      test('no-minimize flag received & preference=true does not minimize',
          () async {
        when(() => storageRepository.getValue('minimizeWindows'))
            .thenAnswer((_) async => true);
        when(() => argParser.minimize).thenReturn(false);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(() => nativePlatform.minimizeWindow(any()));
      });
    });

    group('resuming:', () {
      late Process suspendedProcess;
      late Window suspendedWindow;

      setUp(() {
        suspendedProcess = testProcess.copyWith(
          status: ProcessStatus.suspended,
        );
        suspendedWindow = testWindow.copyWith(process: suspendedProcess);
        when(() => storageRepository.getValue(
              'pid',
              storageArea: kActiveWindowStorageArea,
            )).thenAnswer((_) async => suspendedWindow.process.pid);
        when(() => storageRepository.getValue(
              'windowId',
              storageArea: kActiveWindowStorageArea,
            )).thenAnswer((_) async => suspendedWindow.id);
      });

      test('resumes suspended window', () async {
        when(() => processRepository.resume(suspendedProcess.pid))
            .thenAnswer((_) async => true);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verify(() => processRepository.resume(suspendedProcess.pid)).called(1);
        verify(() => storageRepository.getValue('windowId',
            storageArea: kActiveWindowStorageArea)).called(1);
        verify(() => storageRepository.deleteValue('pid',
            storageArea: kActiveWindowStorageArea)).called(1);
        verify(() => storageRepository.deleteValue('windowId',
            storageArea: kActiveWindowStorageArea)).called(1);
      });

      test('failed resume returns false', () async {
        when(() => processRepository.resume(suspendedProcess.pid))
            .thenAnswer((_) async => false);
        final successful = await activeWindow.toggle();
        expect(successful, false);
        verify(() => processRepository.resume(suspendedProcess.pid)).called(1);
        verifyNever(() => storageRepository.getValue('windowId',
            storageArea: kActiveWindowStorageArea));
        verify(() => storageRepository.deleteValue('pid',
            storageArea: kActiveWindowStorageArea)).called(1);
        verify(() => storageRepository.deleteValue('windowId',
            storageArea: kActiveWindowStorageArea)).called(1);
      });
    });
  });
}
