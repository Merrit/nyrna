import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app_version/app_version.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/hotkey/global/hotkey_service.dart';
import 'package:nyrna/localization/app_localizations.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray_manager.dart';
import 'package:nyrna/window/app_window.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppVersion>(),
  MockSpec<AppWindow>(),
  MockSpec<HotkeyService>(),
  MockSpec<NativePlatform>(),
  MockSpec<ProcessRepository>(),
  MockSpec<SettingsCubit>(),
  MockSpec<StorageRepository>(),
  MockSpec<SystemTrayManager>(),
])
import 'window_tile_test.mocks.dart';

final mockAppVersion = MockAppVersion();
final mockAppWindow = MockAppWindow();
final mockHotkeyService = MockHotkeyService();
final mockNativePlatform = MockNativePlatform();
final mockProcessRepository = MockProcessRepository();
final mockSettingsCubit = MockSettingsCubit();
final mockStorageRepository = MockStorageRepository();
final mockSystemTrayManager = MockSystemTrayManager();

const defaultTestWindow = Window(
  id: 548331,
  process: Process(
    executable: 'firefox-bin',
    pid: 8749655,
    status: ProcessStatus.normal,
  ),
  title: 'Home - KDE Community',
);

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockAppVersion);
    reset(mockHotkeyService);
    reset(mockNativePlatform);
    reset(mockProcessRepository);
    reset(mockSettingsCubit);
    reset(mockStorageRepository);
    reset(mockSystemTrayManager);

    when(mockSettingsCubit.state).thenReturn(SettingsState.initial());
  });

  testWidgets('Window tile renders with personalization', (tester) async {
    final appsListCubit = AppsListCubit(
      appVersion: mockAppVersion,
      appWindow: mockAppWindow,
      hotkeyService: mockHotkeyService,
      nativePlatform: mockNativePlatform,
      processRepository: mockProcessRepository,
      settingsCubit: mockSettingsCubit,
      storage: mockStorageRepository,
      systemTrayManager: mockSystemTrayManager,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
              BlocProvider<AppsListCubit>.value(value: appsListCubit),
            ],
            child: const WindowTile(
              window: defaultTestWindow,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(WindowTile), findsOneWidget);
    expect(find.byKey(const Key('window-tile-pid')), findsOneWidget);

    await appsListCubit.close();
  });

  testWidgets('PID hidden when hideProcessPid is true', (tester) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(hideProcessPid: true),
    );

    final appsListCubit = AppsListCubit(
      appVersion: mockAppVersion,
      appWindow: mockAppWindow,
      hotkeyService: mockHotkeyService,
      nativePlatform: mockNativePlatform,
      processRepository: mockProcessRepository,
      settingsCubit: mockSettingsCubit,
      storage: mockStorageRepository,
      systemTrayManager: mockSystemTrayManager,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
              BlocProvider<AppsListCubit>.value(value: appsListCubit),
            ],
            child: const WindowTile(
              window: defaultTestWindow,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('window-tile-pid')), findsNothing);

    await appsListCubit.close();
  });
}
