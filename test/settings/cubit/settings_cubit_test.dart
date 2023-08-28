import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/apps_list/cubit/apps_list_cubit.dart';
import 'package:nyrna/autostart/autostart_service.dart';
import 'package:nyrna/hotkey/hotkey_service.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/window/app_window.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppsListCubit>(),
  MockSpec<AutostartService>(),
  MockSpec<HotkeyService>(),
  MockSpec<AppWindow>(),
  MockSpec<StorageRepository>(),
])
import 'settings_cubit_test.mocks.dart';

final appsListCubit = MockAppsListCubit();
final appWindow = MockAppWindow();
final autostartService = MockAutostartService();
final hotkeyService = MockHotkeyService();
final storage = MockStorageRepository();

/// Cubit being tested
late SettingsCubit cubit;
SettingsState get state => cubit.state;

void main() {
  setUp((() async {
    reset(appsListCubit);
    reset(appWindow);
    reset(autostartService);
    reset(hotkeyService);
    reset(storage);

    when(autostartService.enable()).thenAnswer((_) async {});
    when(autostartService.disable()).thenAnswer((_) async {});

    when(hotkeyService.addHotkey(any)).thenAnswer((_) async {});
    when(hotkeyService.removeHotkey(any)).thenAnswer((_) async {});

    when(storage.getValue('hotkey')).thenAnswer((_) async {});
    when(storage.deleteValue(any)).thenAnswer((_) async {});
    when(storage.saveValue(
      key: anyNamed('key'),
      value: anyNamed('value'),
    )).thenAnswer((_) async {});
    when(storage.saveValue(
      key: anyNamed('key'),
      value: anyNamed('value'),
    )).thenAnswer((_) async {});
    when(storage.saveValue(
      key: anyNamed('key'),
      value: anyNamed('value'),
    )).thenAnswer((_) async {});

    // StorageRepository
    when(storage.getValue(
      any,
      storageArea: anyNamed('storageArea'),
    )).thenAnswer((_) async => null);
    when(storage.saveValue(
      key: anyNamed('key'),
      value: anyNamed('value'),
      storageArea: anyNamed('storageArea'),
    )).thenAnswer((_) async {});

    cubit = await SettingsCubit.init(
      autostartService: autostartService,
      hotkeyService: hotkeyService,
      storage: storage,
    );
  }));

  group('SettingsCubit:', () {
    test('can be instantiated', () {
      expect(cubit, isA<SettingsCubit>());
    });

    test('instance variable is populated', () {
      expect(settingsCubit, isA<SettingsCubit>());
    });

    test('default state is as expected', () {
      expect(state.autoStart, false);
      expect(state.autoRefresh, true);
      expect(state.closeToTray, false);
      expect(state.hotKey.keyCode, KeyCode.pause);
      expect(state.refreshInterval, 5);
      expect(state.showHiddenWindows, false);
      expect(state.startHiddenInTray, false);
    });

    test('ignoring update works', () async {
      await cubit.ignoreUpdate('1.0.0');
      verify(storage.saveValue(
        key: 'ignoredUpdate',
        value: '1.0.0',
      )).called(1);
    });

    test('setRefreshInterval works', () async {
      const defaultInterval = 5;
      const newInterval = 30;
      expect(state.refreshInterval, defaultInterval);
      await cubit.setRefreshInterval(newInterval);
      expect(state.refreshInterval, newInterval);
      verify(storage.saveValue(
        key: 'refreshInterval',
        value: newInterval,
      )).called(1);
    });

    test('updating autoRefresh works', () async {
      expect(state.autoRefresh, true);
      await cubit.updateAutoRefresh(false);
      expect(state.autoRefresh, false);
      verify(storage.saveValue(
        key: 'autoRefresh',
        value: false,
      )).called(1);
    });

    test('updateCloseToTray works', () async {
      expect(state.closeToTray, false);
      await cubit.updateCloseToTray(true);
      expect(state.closeToTray, true);
      verify(storage.saveValue(
        key: 'closeToTray',
        value: true,
      )).called(1);
    });

    test('updateMinimizeWindows works', () async {
      // Default should be true.
      expect(state.minimizeWindows, true);
      await cubit.updateMinimizeWindows(false);
      expect(state.minimizeWindows, false);
      verify(storage.saveValue(
        key: 'minimizeWindows',
        value: false,
      )).called(1);
      await cubit.updateMinimizeWindows(true);
      expect(state.minimizeWindows, true);
      verify(storage.saveValue(
        key: 'minimizeWindows',
        value: true,
      )).called(1);
    });

    test('updateShowHiddenWindows works', () async {
      expect(state.showHiddenWindows, false);
      await cubit.updateShowHiddenWindows(true);
      expect(state.showHiddenWindows, true);
      verify(storage.saveValue(
        key: 'showHiddenWindows',
        value: true,
      )).called(1);
    });

    test('updateStartHiddenInTray works', () async {
      expect(state.startHiddenInTray, false);
      await cubit.updateStartHiddenInTray(true);
      expect(state.startHiddenInTray, true);
      verify(storage.saveValue(
        key: 'startHiddenInTray',
        value: true,
      )).called(1);
    });

    group('autostart:', () {
      test('disabled by default', () {
        expect(state.autoStart, false);
      });

      test('updating saves preference to storage', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(state.autoStart, false);
        await cubit.toggleAutostart();
        expect(state.autoStart, true);
        verify(storage.saveValue(key: 'autoStart', value: true)).called(1);
        await cubit.toggleAutostart();
        expect(state.autoStart, false);
        verify(storage.saveValue(key: 'autoStart', value: false)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('hotkey:', () {
      test('default hotkey is Pause', () {
        expect(state.hotKey.keyCode, KeyCode.pause);
        expect(state.hotKey.modifiers, null);
      });

      test('removeHotkey works', () async {
        await cubit.removeHotkey();
        verify(hotkeyService.removeHotkey(any)).called(1);
      });

      test('resetting hotkey restores Pause default', () async {
        await cubit.updateHotkey(HotKey(KeyCode.insert));
        expect(state.hotKey.keyCode, KeyCode.insert);
        await cubit.resetHotkey();
        expect(state.hotKey.keyCode, KeyCode.pause);
        verify(storage.deleteValue('hotkey')).called(1);
      });

      test('saved hotkey is loaded', () async {
        when(storage.getValue('hotkey')).thenAnswer(
          (_) async =>
              '{"keyCode":"insert","modifiers":[],"identifier":"7fe60a47-35b9-4d40-8f74-ec77b83687b3","scope":"system"}',
        );
        cubit = await SettingsCubit.init(
          autostartService: autostartService,
          hotkeyService: hotkeyService,
          storage: storage,
        );
        expect(state.hotKey.keyCode, KeyCode.insert);
        expect(state.hotKey.modifiers?.isEmpty, true);
      });

      test('updateHotkey & resetHotkey work', () async {
        final newHotkey = HotKey(KeyCode.f12);
        expect(state.hotKey.keyCode, KeyCode.pause);
        await cubit.updateHotkey(newHotkey);
        expect(state.hotKey.keyCode, KeyCode.f12);
        verify(hotkeyService.addHotkey(newHotkey)).called(1);
        await cubit.resetHotkey();
        expect(state.hotKey.keyCode, KeyCode.pause);
        verify(storage.deleteValue('hotkey')).called(1);
      });
    });
  });
}
