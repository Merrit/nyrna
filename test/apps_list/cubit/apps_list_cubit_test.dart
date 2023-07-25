import 'package:collection/collection.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app_version/app_version.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/hotkey/hotkey_service.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray_manager.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<HotkeyService>(),
  MockSpec<NativePlatform>(),
  MockSpec<SettingsCubit>(),
  MockSpec<ProcessRepository>(),
  MockSpec<StorageRepository>(),
  MockSpec<SystemTrayManager>(),
  MockSpec<AppVersion>(),
])
import 'apps_list_cubit_test.mocks.dart';

late AppsListCubit cubit;
AppsListState get state => cubit.state;

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

Window get msPaintWindowState => state //
    .windows
    .singleWhere((element) => element.id == msPaintWindow.id);

const mpvWindow1 = Window(
  id: 180355074,
  process: Process(
    executable: 'mpv',
    pid: 1355281,
    status: ProcessStatus.normal,
  ),
  title: 'No file - mpv',
);

Window get mpvWindow1State => state //
    .windows
    .singleWhere((element) => element.id == mpvWindow1.id);

const mpvWindow2 = Window(
  id: 197132290,
  process: Process(
    executable: 'mpv',
    pid: 1355477,
    status: ProcessStatus.normal,
  ),
  title: 'No file - mpv',
);

Window get mpvWindow2State => state //
    .windows
    .singleWhere((element) => element.id == mpvWindow2.id);

final hotkeyService = MockHotkeyService();
final nativePlatform = MockNativePlatform();
final settingsCubit = MockSettingsCubit();
final processRepository = MockProcessRepository();
final storage = MockStorageRepository();
final systemTrayManager = MockSystemTrayManager();
final appVersion = MockAppVersion();

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(hotkeyService);
    reset(nativePlatform);
    reset(settingsCubit);
    reset(processRepository);
    reset(storage);
    reset(systemTrayManager);
    reset(appVersion);

    when(appVersion.latest()).thenAnswer((_) async => '1.0.0');
    when(appVersion.running()).thenReturn('1.0.0');
    when(appVersion.updateAvailable()).thenAnswer((_) async => false);

    when(nativePlatform.minimizeWindow(any)).thenAnswer((_) async => true);
    when(nativePlatform.restoreWindow(any)).thenAnswer((_) async => true);
    when(nativePlatform.windows(showHidden: anyNamed('showHidden')))
        .thenAnswer((_) async => []);

    when(storage.getValue('ignoredUpdate')).thenAnswer((_) async {});

    when(settingsCubit.state).thenReturn(
      SettingsState(
        autoStart: false,
        autoRefresh: false,
        closeToTray: false,
        hotKey: HotKey(KeyCode.again),
        minimizeWindows: true,
        refreshInterval: 5,
        showHiddenWindows: false,
        startHiddenInTray: false,
        working: false,
      ),
    );

    when(processRepository.getProcessStatus(any))
        .thenAnswer((_) async => ProcessStatus.normal);
    when(processRepository.resume(any)).thenAnswer((_) async => true);
    when(processRepository.suspend(any)).thenAnswer((_) async => true);

    // StorageRepository
    when(storage.getValue('minimizeWindows')).thenAnswer((_) async => true);

    cubit = AppsListCubit(
      hotkeyService: hotkeyService,
      nativePlatform: nativePlatform,
      settingsCubit: settingsCubit,
      processRepository: processRepository,
      storage: storage,
      appVersion: appVersion,
      systemTrayManager: systemTrayManager,
      testing: true,
    );
  });

  group('AppCubit:', () {
    test('initial state has no windows', () {
      expect(state.windows.length, 0);
    });

    test('new window is added to state', () async {
      expect(state.windows.length, 0);

      when(nativePlatform.windows(showHidden: anyNamed('showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);

      await cubit.manualRefresh();
      expect(state.windows.length, 1);
    });

    test('process changed externally updates state', () async {
      when(nativePlatform.windows(showHidden: anyNamed('showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);

      await cubit.manualRefresh();

      // Verify we have one window, and it has a normal status.
      var windows = state.windows;
      expect(windows.length, 1);
      expect(windows[0].process.status, ProcessStatus.normal);

      // Simulate the process being suspended outside Nyrna.
      reset(processRepository);
      when(processRepository.getProcessStatus(any))
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
      when(appVersion.latest()).thenAnswer((_) async => '1.0.1');
      when(appVersion.updateAvailable()).thenAnswer((_) async => true);
      await cubit.fetchVersionData();
      expect(state.runningVersion, '1.0.0');
      expect(state.updateVersion, '1.0.1');
      expect(state.updateAvailable, true);
    });

    test('windows are sorted', () async {
      when(nativePlatform.windows(showHidden: anyNamed('showHidden')))
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
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [msPaintWindow]);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);

        when(processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.toggle(msPaintWindow);
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.suspended);
      });

      test('resumes correctly', () async {
        expect(state.windows.isEmpty, true);
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [msPaintWindow]);
        when(processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.suspended);

        when(processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.toggle(msPaintWindow);
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);
      });

      test('adds InteractionError to window on failure', () async {
        expect(state.windows.isEmpty, true);
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [msPaintWindow]);
        when(processRepository.getProcessStatus(msPaintProcess.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.manualRefresh();
        expect(state.windows.length, 1);
        expect(state.windows.first.process.status, ProcessStatus.normal);

        when(processRepository.suspend(any)).thenAnswer((_) async => false);
        when(processRepository.getProcessStatus(msPaintProcess.pid))
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

    group('toggleAll', () {
      test('suspends multiple instances correctly', () async {
        // Initial setup.
        expect(state.windows.isEmpty, true);
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [
              msPaintWindow,
              mpvWindow1,
              mpvWindow2,
            ]);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.normal);
        expect(mpvWindow2State.process.status, ProcessStatus.normal);

        // Trigger toggleAll() to suspend mpv instances and verify.
        await cubit.toggleAll(mpvWindow1);
        when(processRepository.getProcessStatus(mpvWindow1.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        when(processRepository.getProcessStatus(mpvWindow2.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.suspended);
        expect(mpvWindow2State.process.status, ProcessStatus.suspended);
      });

      test('resumes multiple instances correctly', () async {
        // Initial setup.
        expect(state.windows.isEmpty, true);
        when(processRepository.getProcessStatus(mpvWindow1.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        when(processRepository.getProcessStatus(mpvWindow2.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [
              msPaintWindow,
              mpvWindow1.copyWith(
                process: mpvWindow1.process.copyWith(
                  status: ProcessStatus.suspended,
                ),
              ),
              mpvWindow2.copyWith(
                process: mpvWindow2.process.copyWith(
                  status: ProcessStatus.suspended,
                ),
              ),
            ]);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.suspended);
        expect(mpvWindow2State.process.status, ProcessStatus.suspended);

        // Trigger toggleAll() to resume mpv instances and verify.
        await cubit.toggleAll(mpvWindow1);
        when(processRepository.getProcessStatus(mpvWindow1.process.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        when(processRepository.getProcessStatus(mpvWindow2.process.pid))
            .thenAnswer((_) async => ProcessStatus.normal);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.normal);
        expect(mpvWindow2State.process.status, ProcessStatus.normal);
      });

      test('only suspends if some are already suspended', () async {
        // Initial setup.
        expect(state.windows.isEmpty, true);
        when(processRepository.getProcessStatus(mpvWindow2.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        when(nativePlatform.windows(
          showHidden: anyNamed('showHidden'),
        )).thenAnswer((_) async => [
              msPaintWindow,
              mpvWindow1,
              mpvWindow2.copyWith(
                process: mpvWindow2.process.copyWith(
                  status: ProcessStatus.suspended,
                ),
              ),
            ]);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.normal);
        expect(mpvWindow2State.process.status, ProcessStatus.suspended);

        // Trigger toggleAll() to suspend mpv instances and verify,
        // the already suspended instance should not have resumed.
        await cubit.toggleAll(mpvWindow1);
        when(processRepository.getProcessStatus(mpvWindow1.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        when(processRepository.getProcessStatus(mpvWindow2.process.pid))
            .thenAnswer((_) async => ProcessStatus.suspended);
        await cubit.manualRefresh();
        expect(state.windows.length, 3);
        expect(msPaintWindowState.process.status, ProcessStatus.normal);
        expect(mpvWindow1State.process.status, ProcessStatus.suspended);
        expect(mpvWindow2State.process.status, ProcessStatus.suspended);
      });
    });
  });
}
