import 'package:collection/collection.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:test/test.dart';

import '../../mock_app_version.dart';
import '../../mock_native_platform.dart';
import '../../mock_settings_cubit.dart';
import '../../mock_settings_service.dart';

class MockProcessRepository extends Mock implements ProcessRepository {}

class MockStorageRepository extends Mock implements StorageRepository {}

const msPaintProcess = Process(
  executable: 'mspaint.exe',
  pid: 3716,
  status: ProcessStatus.normal,
);

const msPaintWindow = Window(
  id: 132334,
  process: msPaintProcess,
  title: 'Untitled - Paint',
);

late AppsListCubit cubit;
AppsListState get state => cubit.state;

void main() {
  final nativePlatform = MockNativePlatform();
  final prefs = MockSettingsService();
  final prefsCubit = MockSettingsCubit();
  final processRepository = MockProcessRepository();
  final storageRepository = MockStorageRepository();
  final appVersion = MockAppVersion();

  setUpAll(() {
    log = Logger();
  });

  setUp(() {
    when(() => appVersion.latest()).thenAnswer((_) async => '1.0.0');
    when(() => appVersion.updateAvailable()).thenAnswer((_) async => false);

    when(() => nativePlatform.minimizeWindow(any()))
        .thenAnswer((_) async => true);
    when(() => nativePlatform.restoreWindow(any()))
        .thenAnswer((_) async => true);
    when(() => nativePlatform.windows(showHidden: any(named: 'showHidden')))
        .thenAnswer((_) async => []);

    when(() => prefs.getString('ignoredUpdate')).thenReturn(null);

    when(() => prefsCubit.state).thenReturn(
      SettingsState(
        autoStart: false,
        autoRefresh: false,
        closeToTray: false,
        hotKey: HotKey(KeyCode.again),
        minimizeWindows: true,
        refreshInterval: 5,
        showHiddenWindows: false,
        startHiddenInTray: false,
      ),
    );

    when(() => processRepository.getProcessStatus(any()))
        .thenAnswer((_) async => ProcessStatus.normal);
    when(() => processRepository.resume(any())).thenAnswer((_) async => true);
    when(() => processRepository.suspend(any())).thenAnswer((_) async => true);

    // StorageRepository
    when(() => storageRepository.getValue('minimizeWindows'))
        .thenAnswer((_) async => true);

    cubit = AppsListCubit(
      nativePlatform: nativePlatform,
      prefs: prefs,
      prefsCubit: prefsCubit,
      processRepository: processRepository,
      appVersion: appVersion,
      testing: true,
    );
  });

  group('AppCubit:', () {
    test('initial state has no windows', () {
      expect(state.windows.length, 0);
    });

    test('new window is added to state', () async {
      expect(state.windows.length, 0);

      when(() => nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);

      await cubit.manualRefresh();
      expect(state.windows.length, 1);
    });

    test('process changed externally updates state', () async {
      when(() => nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);

      await cubit.manualRefresh();

      // Verify we have one window, and it has a normal status.
      var windows = state.windows;
      expect(windows.length, 1);
      expect(windows[0].process.status, ProcessStatus.normal);

      // Simulate the process being suspended outside Nyrna.
      reset(processRepository);
      when(() => processRepository.getProcessStatus(any()))
          .thenAnswer((_) async => ProcessStatus.suspended);

      // Verify we pick up this status change.
      await cubit.manualRefresh();
      windows = state.windows;
      expect(windows.length, 1);
      expect(windows[0].process.status, ProcessStatus.suspended);
    });

    test('app version information populates to cubit', () async {
      // Verify initial state is unpopulated.
      expect(state.runningVersion, '');
      expect(state.updateVersion, '');
      expect(state.updateAvailable, false);

      // Stubbed data propogates.
      await cubit.fetchVersionData();
      expect(state.runningVersion, '1.0.0');
      expect(state.updateVersion, '1.0.0');
      expect(state.updateAvailable, false);

      // Simulate an update being available.
      when(() => appVersion.latest()).thenAnswer((_) async => '1.0.1');
      when(() => appVersion.updateAvailable()).thenAnswer((_) async => true);
      await cubit.fetchVersionData();
      expect(state.runningVersion, '1.0.0');
      expect(state.updateVersion, '1.0.1');
      expect(state.updateAvailable, true);
    });

    test('windows are sorted', () async {
      when(() => nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [
                const Window(
                  id: 7363,
                  process: Process(
                    executable: 'kate',
                    pid: 836482,
                    status: ProcessStatus.normal,
                  ),
                  title: 'Kate',
                ),
                const Window(
                  id: 29347,
                  process: Process(
                    executable: 'evince',
                    pid: 94847,
                    status: ProcessStatus.normal,
                  ),
                  title: 'Evince',
                ),
                const Window(
                  id: 89374,
                  process: Process(
                    executable: 'ark',
                    pid: 9374623,
                    status: ProcessStatus.normal,
                  ),
                  title: 'Ark',
                ),
              ]);

      await cubit.manualRefresh();
      final windows = state.windows;
      expect(windows[0].process.executable, 'ark');
      expect(windows[1].process.executable, 'evince');
      expect(windows[2].process.executable, 'kate');
    });

    group('toggle:', () {
      test('suspends correctly', () async {
        expect(state.windows.isEmpty, true);
        when(() => nativePlatform.windows(
              showHidden: any(named: 'showHidden'),
            )).thenAnswer((_) async => [msPaintWindow]);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);

        when(() => processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.toggle(msPaintWindow);
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.suspended);
      });

      test('resumes correctly', () async {
        expect(state.windows.isEmpty, true);
        when(() => nativePlatform.windows(
              showHidden: any(named: 'showHidden'),
            )).thenAnswer((_) async => [msPaintWindow]);
        when(() => processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.suspended);

        when(() => processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.toggle(msPaintWindow);
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);
      });

      test('adds InteractionError to window on failure', () async {
        expect(state.windows.isEmpty, true);
        when(() => nativePlatform.windows(
              showHidden: any(named: 'showHidden'),
            )).thenAnswer((_) async => [msPaintWindow]);
        when(() => processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);

        when(() => processRepository.suspend(any()))
            .thenAnswer((_) async => false);
        when(() => processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.toggle(msPaintWindow);
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);
        final interactionError = state //
            .interactionErrors
            .singleWhereOrNull((e) => e.windowId == msPaintWindow.id);
        expect(interactionError, isNotNull);
        expect(interactionError!.interactionType, InteractionType.suspend);
        expect(interactionError.statusAfterInteraction, ProcessStatus.normal);
      });
    });
  });
}
