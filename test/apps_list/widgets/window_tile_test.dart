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

const secondFirefoxWindow = Window(
  id: 548332,
  process: Process(
    executable: 'firefox-bin',
    pid: 8749656,
    status: ProcessStatus.normal,
  ),
  title: 'KDE Discuss - Firefox',
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

  testWidgets('Clicking more actions button shows context menu', (tester) async {
    final appsListCubit = await _pumpWindowTile(tester);

    await tester.tap(find.byType(MenuAnchor));
    await tester.pumpAndSettle();

    expect(find.text('Suspend all instances'), findsOneWidget);

    await appsListCubit.close();
  });

  testWidgets('PID line respects hideProcessPid flag', (tester) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(hideProcessPid: true),
    );

    final appsListCubit = await _pumpWindowTile(tester);
    expect(find.byKey(const Key('window-tile-pid')), findsNothing);
    await appsListCubit.close();
  });

  testWidgets('Executable moves to title when showExecutableFirst is enabled', (
    tester,
  ) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(showExecutableFirst: true),
    );

    final appsListCubit = await _pumpWindowTile(tester);
    expect(
      find.byKey(const Key('window-tile-executable-first')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('window-tile-executable-subtitle')),
      findsNothing,
    );
    await appsListCubit.close();
  });

  testWidgets('ListTile shrinks inner padding when compactCards is enabled', (
    tester,
  ) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(compactCards: true),
    );

    final appsListCubit = await _pumpWindowTile(tester);

    final ListTile listTile = tester.widget(find.byType(ListTile));
    expect(listTile.dense, true);
    expect(
      listTile.contentPadding,
      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
    );

    await appsListCubit.close();
  });

  testWidgets('Card margin tightens with compactCards', (tester) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(compactCards: true),
    );

    final appsListCubit = await _pumpWindowTile(tester);
    final Card card = tester.widget(find.byType(Card));
    expect(
      card.margin,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    );

    await appsListCubit.close();
  });

  testWidgets('compact mode title uses tighter font size', (tester) async {
    when(mockSettingsCubit.state).thenReturn(
      SettingsState.initial().copyWith(compactCards: true),
    );

    final appsListCubit = await _pumpWindowTile(tester);
    final Text titleText = tester.widget(find.byKey(const Key('window-tile-title')));
    expect(titleText.style?.fontSize, 14.2);
    await appsListCubit.close();
  });

  testWidgets('only first same-executable card keeps primary toggle', (
    tester,
  ) async {
    when(
      mockNativePlatform.windows(showHidden: anyNamed('showHidden')),
    ).thenAnswer((_) async => [defaultTestWindow, secondFirefoxWindow]);

    final appsListCubit = await _pumpWindowTiles(
      tester,
      const [defaultTestWindow, secondFirefoxWindow],
    );

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles.length, 2);
    expect(tiles.first.onTap, isNotNull);
    expect(tiles.last.onTap, isNull);

    await appsListCubit.close();
  });
}

/// Pumps [WindowTile] with the required bloc providers.
Future<AppsListCubit> _pumpWindowTile(WidgetTester tester) async {
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
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: mockSettingsCubit),
            BlocProvider.value(value: appsListCubit),
          ],
          child: const WindowTile(
            window: defaultTestWindow,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return appsListCubit;
}

Future<AppsListCubit> _pumpWindowTiles(
  WidgetTester tester,
  List<Window> windows,
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
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: mockSettingsCubit),
            BlocProvider.value(value: appsListCubit),
          ],
          child: Column(
            children: windows
                .map(
                  (window) => WindowTile(
                    window: window,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return appsListCubit;
}
