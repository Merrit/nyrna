import 'dart:async';

import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray.dart';
import 'package:nyrna/updates/updates.dart';
import 'package:nyrna/window/app_window.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppWindow>(),
  MockSpec<NativePlatform>(),
  MockSpec<ReleaseNotesService>(),
  MockSpec<StorageRepository>(),
  MockSpec<SystemTrayManager>(),
  MockSpec<UpdateService>(),
])
import 'app_cubit_test.mocks.dart';

final mockAppWindow = MockAppWindow();
final mockNativePlatform = MockNativePlatform();
final mockReleaseNotesService = MockReleaseNotesService();
final mockStorageRepo = MockStorageRepository();
final mockSystemTrayManager = MockSystemTrayManager();
final mockUpdateService = MockUpdateService();

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockAppWindow);
    reset(mockNativePlatform);
    reset(mockReleaseNotesService);
    reset(mockStorageRepo);
    reset(mockSystemTrayManager);
    reset(mockUpdateService);

    when(mockUpdateService.getVersionInfo()).thenAnswer((_) async => VersionInfo.empty());

    cubit = AppCubit(
      mockAppWindow,
      mockNativePlatform,
      mockReleaseNotesService,
      mockStorageRepo,
      mockSystemTrayManager,
      mockUpdateService,
    );
  });

  group('AppCubit:', () {
    test('firstRun default is true', () {
      // This test may require a delay if the cubit's init takes longer.
      expect(state.firstRun, true);
    });
  });

  group('AppCubit - first run:', () {
    test(
      'when storage returns null for firstRun, state has firstRun: true after init',
      () async {
        when(
          mockStorageRepo.getValue('firstRun'),
        ).thenAnswer((_) async => null);

        final testCubit = AppCubit(
          mockAppWindow,
          mockNativePlatform,
          mockReleaseNotesService,
          mockStorageRepo,
          mockSystemTrayManager,
          mockUpdateService,
        );

        // Allow async _init() to complete.
        await Future<void>.delayed(Duration.zero);

        expect(testCubit.state.firstRun, true);
      },
    );

    test(
      'when storage returns false for firstRun, state has firstRun: false after init',
      () async {
        when(
          mockStorageRepo.getValue('firstRun'),
        ).thenAnswer((_) async => false);

        final testCubit = AppCubit(
          mockAppWindow,
          mockNativePlatform,
          mockReleaseNotesService,
          mockStorageRepo,
          mockSystemTrayManager,
          mockUpdateService,
        );

        await Future<void>.delayed(Duration.zero);

        expect(testCubit.state.firstRun, false);
      },
    );

    test('userAcceptedDisclaimer() saves firstRun: false to storage', () async {
      // Allow async _init() (which may also call saveValue) to complete first.
      await Future<void>.delayed(Duration.zero);
      reset(mockStorageRepo);

      await cubit.userAcceptedDisclaimer();

      verify(
        mockStorageRepo.saveValue(key: 'firstRun', value: false),
      ).called(1);
    });

    test('userAcceptedDisclaimer() emits state with firstRun: false', () async {
      await cubit.userAcceptedDisclaimer();

      expect(state.firstRun, false);
    });
  });

  group('AppCubit - version fetching:', () {
    test(
      '_fetchVersionData() populates state with version information',
      () async {
        const populatedVersionInfo = VersionInfo(
          currentVersion: '2.0.0',
          latestVersion: '2.1.0',
          updateAvailable: true,
        );
        when(
          mockUpdateService.getVersionInfo(),
        ).thenAnswer((_) async => populatedVersionInfo);

        final testCubit = AppCubit(
          mockAppWindow,
          mockNativePlatform,
          mockReleaseNotesService,
          mockStorageRepo,
          mockSystemTrayManager,
          mockUpdateService,
        );

        // Wait for _init() async operations to complete.
        await Future<void>.delayed(Duration.zero);

        expect(testCubit.state.runningVersion, '2.0.0');
        expect(testCubit.state.updateVersion, '2.1.0');
        expect(testCubit.state.updateAvailable, true);

        await testCubit.close();
      },
    );

    test(
      'when getVersionInfo() throws, state is not corrupted',
      () async {
        when(
          mockUpdateService.getVersionInfo(),
        ).thenThrow(Exception('Network error'));

        final testCubit = AppCubit(
          mockAppWindow,
          mockNativePlatform,
          mockReleaseNotesService,
          mockStorageRepo,
          mockSystemTrayManager,
          mockUpdateService,
        );

        // Wait for _init() async operations to complete.
        await Future<void>.delayed(Duration.zero);

        // State should remain at initial values when fetching throws.
        expect(testCubit.state.runningVersion, '');
        expect(testCubit.state.updateAvailable, false);

        await testCubit.close();
      },
    );
  });

  group('AppCubit - system tray events:', () {
    late StreamController<SystemTrayEvent> trayEventController;
    late MockSystemTrayManager localSystemTrayManager;
    late AppCubit testCubit;

    setUp(() async {
      localSystemTrayManager = MockSystemTrayManager();
      trayEventController = StreamController<SystemTrayEvent>();
      when(
        localSystemTrayManager.eventStream,
      ).thenAnswer((_) => trayEventController.stream);

      testCubit = AppCubit(
        mockAppWindow,
        mockNativePlatform,
        mockReleaseNotesService,
        mockStorageRepo,
        localSystemTrayManager,
        mockUpdateService,
      );

      // Wait for _init() to complete so _listenToSystemTrayEvents() has subscribed.
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      await trayEventController.close();
      await testCubit.close();
    });

    test('SystemTrayEvent.windowShow calls appWindow.show()', () async {
      trayEventController.add(SystemTrayEvent.windowShow);
      await Future<void>.delayed(Duration.zero);

      verify(mockAppWindow.show()).called(1);
    });

    test('SystemTrayEvent.exit calls appWindow.close()', () async {
      trayEventController.add(SystemTrayEvent.exit);
      await Future<void>.delayed(Duration.zero);

      verify(mockAppWindow.close()).called(1);
    });
  });
}
