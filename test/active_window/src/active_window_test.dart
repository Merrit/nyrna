import 'package:flutter/foundation.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/active_window/active_window.dart';
import 'package:nyrna/argument_parser/argument_parser.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/window/app_window.dart';
import 'package:test/test.dart';

import '../../helpers.dart';
@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppWindow>(),
  MockSpec<ArgumentParser>(),
  MockSpec<NativePlatform>(),
  MockSpec<ProcessRepository>(),
  MockSpec<StorageRepository>(),
])
import 'active_window_test.mocks.dart';

const kActiveWindowStorageArea = 'activeWindow';

const testProcess = Process(
  executable: 'code-insiders',
  pid: 45686,
  status: ProcessStatus.normal,
);

const testWindow = Window(
  id: '130023427',
  process: testProcess,
  title: 'Untitled-2 - Visual Studio Code - Insiders',
);

MockAppWindow appWindow = MockAppWindow();
MockArgumentParser argParser = MockArgumentParser();
MockNativePlatform nativePlatform = MockNativePlatform();
MockProcessRepository processRepository = MockProcessRepository();
MockStorageRepository storageRepository = MockStorageRepository();

late ActiveWindow activeWindow;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(argParser);
    ArgumentParser.instance = argParser;
    reset(nativePlatform);
    reset(processRepository);
    reset(storageRepository);

    // Setup initial dummy responses for mocks.

    // AppWindow
    when(appWindow.hide()).thenAnswer((_) async => true);

    // NativePlatform
    when(nativePlatform.activeWindow).thenReturn(testWindow);
    when(nativePlatform.minimizeWindow(any)).thenAnswer((_) async => true);
    when(nativePlatform.restoreWindow(any)).thenAnswer((_) async => true);

    // ProcessRepository
    when(processRepository.suspend(any)).thenAnswer((_) async => true);

    // StorageRepository
    when(storageRepository.deleteValue(
      any,
      storageArea: anyNamed('storageArea'),
    )).thenAnswer((_) async {});
    when(storageRepository.getValue(
      any,
      storageArea: anyNamed('storageArea'),
    )).thenAnswer((_) async => null);
    when(storageRepository.saveValue(
      key: anyNamed('key'),
      value: anyNamed('value'),
      storageArea: anyNamed('storageArea'),
    )).thenAnswer((_) async {});
    when(storageRepository.close()).thenAnswer((_) async {});

    activeWindow = ActiveWindow(
      appWindow,
      nativePlatform,
      processRepository,
      storageRepository,
    );
  });

  group('ActiveWindow:', () {
    test('suspends normal window', () async {
      final successful = await activeWindow.toggle();
      expect(successful, true);
      verify(processRepository.suspend(testWindow.process.pid)).called(1);
      verify(storageRepository.saveValue(
        key: 'pid',
        value: testWindow.process.pid,
        storageArea: kActiveWindowStorageArea,
      )).called(1);
      verify(storageRepository.saveValue(
        key: 'windowId',
        value: testWindow.id,
        storageArea: kActiveWindowStorageArea,
      )).called(1);
    });

    test('explorer.exe executable aborts on Win32', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      when(nativePlatform.activeWindow).thenReturn(testWindow.copyWith(
            process: testProcess.copyWith(executable: 'explorer.exe'),
          ));
      final successful = await activeWindow.toggle();
      expect(successful, false);
      verifyNever(processRepository.suspend(any));
      // Restore global platform variable.
      debugDefaultTargetPlatformOverride = null;
    });

    test('suspend failure returns false', () async {
      when(processRepository.suspend(any)).thenAnswer((_) async => false);
      final successful = await activeWindow.toggle();
      expect(successful, false);
    });

    test('active window being Nyrna calls hide on window and tries again (Linux)',
        () async {
      final nyrnaWindow = testWindow.copyWith(
        process: testProcess.copyWith(executable: 'nyrna'),
      );
      when(nativePlatform.activeWindow).thenReturnInOrder([
        nyrnaWindow,
        testWindow,
      ]);
      await nativePlatform.checkActiveWindow();
      final successful = await activeWindow.toggle();
      expect(successful, true);
      verify(nativePlatform.checkActiveWindow()).called(2);
      verify(appWindow.hide()).called(1);
    });

    test('active window being Nyrna calls hide on window and tries again (Windows)',
        () async {
      final nyrnaWindow = testWindow.copyWith(
        process: testProcess.copyWith(executable: 'nyrna.exe'),
      );
      when(nativePlatform.activeWindow).thenReturnInOrder([
        nyrnaWindow,
        testWindow,
      ]);
      await nativePlatform.checkActiveWindow();
      final successful = await activeWindow.toggle();
      expect(successful, true);
      verify(nativePlatform.checkActiveWindow()).called(2);
      verify(appWindow.hide()).called(1);
    });

    group('minimizing & restoring:', () {
      test('no flag or preference defaults to minimizing', () async {
        expect(argParser.minimize, null);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verify(nativePlatform.minimizeWindow(any)).called(1);
      });

      test('no flag & preference=false does not minimize', () async {
        when(storageRepository.getValue('minimizeWindows'))
            .thenAnswer((_) async => false);
        expect(argParser.minimize, null);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(nativePlatform.minimizeWindow(any));
      });

      test('no-minimize flag received & no preference does not minimize', () async {
        when(argParser.minimize).thenReturn(false);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(nativePlatform.minimizeWindow(any));
      });

      test('no-minimize flag received & preference=true does not minimize', () async {
        when(storageRepository.getValue('minimizeWindows')).thenAnswer((_) async => true);
        when(argParser.minimize).thenReturn(false);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verifyNever(nativePlatform.minimizeWindow(any));
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
        when(storageRepository.getValue(
          'pid',
          storageArea: kActiveWindowStorageArea,
        )).thenAnswer((_) async => suspendedWindow.process.pid);
        when(storageRepository.getValue(
          'windowId',
          storageArea: kActiveWindowStorageArea,
        )).thenAnswer((_) async => suspendedWindow.id);
      });

      test('resumes suspended window', () async {
        when(processRepository.resume(suspendedProcess.pid))
            .thenAnswer((_) async => true);
        final successful = await activeWindow.toggle();
        expect(successful, true);
        verify(processRepository.resume(suspendedProcess.pid)).called(1);
        verify(storageRepository.getValue('windowId',
                storageArea: kActiveWindowStorageArea))
            .called(1);
        verify(storageRepository.deleteValue('pid',
                storageArea: kActiveWindowStorageArea))
            .called(1);
        verify(storageRepository.deleteValue('windowId',
                storageArea: kActiveWindowStorageArea))
            .called(1);
      });

      test('failed resume returns false', () async {
        when(processRepository.resume(suspendedProcess.pid))
            .thenAnswer((_) async => false);
        final successful = await activeWindow.toggle();
        expect(successful, false);
        verify(processRepository.resume(suspendedProcess.pid)).called(1);
        verifyNever(storageRepository.getValue('windowId',
            storageArea: kActiveWindowStorageArea));
        verify(storageRepository.deleteValue('pid',
                storageArea: kActiveWindowStorageArea))
            .called(1);
        verify(storageRepository.deleteValue('windowId',
                storageArea: kActiveWindowStorageArea))
            .called(1);
      });
    });
  });
}
