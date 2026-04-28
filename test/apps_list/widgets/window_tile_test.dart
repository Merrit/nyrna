import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app_version/app_version.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/hotkey/global/hotkey_service.dart';
import 'package:nyrna/localization/app_localizations.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray_manager.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/window/app_window.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppsListCubit>(),
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

final mockAppsListCubit = MockAppsListCubit();
final mockAppVersion = MockAppVersion();
final mockAppWindow = MockAppWindow();
final mockHotkeyService = MockHotkeyService();
final mockNativePlatform = MockNativePlatform();
final mockProcessRepository = MockProcessRepository();
final mockSettingsCubit = MockSettingsCubit();
final mockStorageRepository = MockStorageRepository();
final mockSystemTrayManager = MockSystemTrayManager();

const defaultTestWindow = Window(
  id: '548331',
  process: Process(
    executable: 'firefox-bin',
    pid: 8749655,
    status: ProcessStatus.normal,
  ),
  title: 'Home - KDE Community',
);

const suspendedTestWindow = Window(
  id: '123456',
  process: Process(
    executable: 'some_app',
    pid: 12345,
    status: ProcessStatus.suspended,
  ),
  title: 'Suspended Window Title',
);

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockAppsListCubit);
    reset(mockAppVersion);
    reset(mockHotkeyService);
    reset(mockNativePlatform);
    reset(mockProcessRepository);
    reset(mockSettingsCubit);
    reset(mockStorageRepository);
    reset(mockSystemTrayManager);

    when(mockSettingsCubit.state).thenReturn(SettingsState.initial());
    when(mockAppsListCubit.state).thenReturn(AppsListState.initial());
    when(mockAppsListCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Clicking more actions button shows context menu', (tester) async {
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: appsListCubit,
            child: const WindowTile(
              window: defaultTestWindow,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MenuAnchor));
    await tester.pumpAndSettle();

    expect(find.text('Suspend all instances'), findsOneWidget);

    await appsListCubit.close();
  });

  testWidgets('Tile displays window title and process executable', (
    tester,
  ) async {
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: appsListCubit,
            child: const WindowTile(window: defaultTestWindow),
          ),
        ),
      ),
    );

    expect(find.text('Home - KDE Community'), findsOneWidget);
    expect(find.text('firefox-bin'), findsOneWidget);
    expect(find.text('PID: 8749655'), findsOneWidget);

    await appsListCubit.close();
  });

  testWidgets('Suspended window shows orange status indicator', (
    tester,
  ) async {
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: appsListCubit,
            child: const WindowTile(window: suspendedTestWindow),
          ),
        ),
      ),
    );

    final orangeCircle = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.orange[700],
    );
    expect(orangeCircle, findsOneWidget);

    await appsListCubit.close();
  });

  testWidgets('Tapping tile calls toggle on the cubit', (tester) async {
    when(
      mockAppsListCubit.toggle(defaultTestWindow),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<AppsListCubit>.value(
            value: mockAppsListCubit,
            child: const WindowTile(window: defaultTestWindow),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    verify(mockAppsListCubit.toggle(defaultTestWindow)).called(1);
  });
}
