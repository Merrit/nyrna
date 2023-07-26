import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app_version/app_version.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/hotkey/hotkey_service.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray_manager.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppVersion>(),
  MockSpec<HotkeyService>(),
  MockSpec<NativePlatform>(),
  MockSpec<ProcessRepository>(),
  MockSpec<SettingsCubit>(),
  MockSpec<StorageRepository>(),
  MockSpec<SystemTrayManager>(),
])
import 'window_tile_test.mocks.dart';

final mockAppVersion = MockAppVersion();
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

  testWidgets('Right-click shows context menu', (tester) async {
    final appsListCubit = AppsListCubit(
      appVersion: mockAppVersion,
      hotkeyService: mockHotkeyService,
      nativePlatform: mockNativePlatform,
      processRepository: mockProcessRepository,
      settingsCubit: mockSettingsCubit,
      storage: mockStorageRepository,
      systemTrayManager: mockSystemTrayManager,
    );

    await tester.pumpWidget(
      MaterialApp(
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

    await tester.tap(find.byType(WindowTile), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    expect(find.text('Suspend all instances of firefox-bin'), findsOneWidget);

    await appsListCubit.close();
  });
}
