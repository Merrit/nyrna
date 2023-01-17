import 'dart:ui';

import 'package:desktop_integration/desktop_integration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/apps_list/cubit/apps_list_cubit.dart';
import 'package:nyrna/core/helpers/helpers.dart';
import 'package:nyrna/hotkey/hotkey_service.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/window/nyrna_window.dart';
import 'package:window_size/window_size.dart';

class FakeDesktopIntegration extends Fake implements DesktopIntegration {
  @override
  Future<void> disableAutostart() async {}

  @override
  Future<void> enableAutostart() async {}
}

/// Mocks

class MockAppsListCubit extends Mock implements AppsListCubit {}

class MockHotkeyService extends Mock implements HotkeyService {}

class MockNyrnaWindow extends Mock implements NyrnaWindow {}

class MockSettingsService extends Mock implements SettingsService {}

class MockStorageRepository extends Mock implements StorageRepository {}

late Future<PlatformWindow> Function() getWindowInfo;
HotkeyService hotkeyService = MockHotkeyService();
NyrnaWindow nyrnaWindow = MockNyrnaWindow();
SettingsService settingsService = MockSettingsService();
StorageRepository storageRepository = MockStorageRepository();

/// Cubit being tested

late SettingsCubit cubit;
SettingsState get state => cubit.state;

void main() {
  final fallbackPlatformWindow = PlatformWindow(
    const Rect.fromLTWH(0, 0, 100, 100),
    1,
    null,
  );

  setUpAll((() {
    appsListCubit = MockAppsListCubit();
    when(() => appsListCubit.setAutoRefresh(
          autoRefresh: any(named: 'autoRefresh'),
          refreshInterval: any(named: 'refreshInterval'),
        )).thenReturn(null);

    getWindowInfo = () async => fallbackPlatformWindow;
    registerFallbackValue(HotKey(KeyCode.abort));
  }));

  setUp((() async {
    when(() => hotkeyService.updateHotkey(any())).thenAnswer((_) async {});
    when(() => hotkeyService.removeHotkey()).thenAnswer((_) async {});

    when(() => nyrnaWindow.preventClose(any())).thenAnswer((_) async {});

    when(() => settingsService.getString('hotkey')).thenReturn(null);
    when(() => settingsService.remove(any())).thenAnswer((_) async => true);
    when(() => settingsService.setBool(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => settingsService.setInt(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => settingsService.setString(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});

    // StorageRepository
    when(() => storageRepository.getValue(
          any(),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async => null);
    when(() => storageRepository.saveValue(
          key: any(named: 'key'),
          value: any(named: 'value'),
          storageArea: any(named: 'storageArea'),
        )).thenAnswer((_) async {});

    cubit = await SettingsCubit.init(
      desktopIntegration: FakeDesktopIntegration(),
      getWindowInfo: getWindowInfo,
      prefs: settingsService,
      hotkeyService: hotkeyService,
      nyrnaWindow: nyrnaWindow,
      storageRepository: storageRepository,
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
      verify(() => settingsService.setString(
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
      verify((() => settingsService.setInt(
            key: 'refreshInterval',
            value: newInterval,
          ))).called(1);
    });

    test('updating autoRefresh works', () async {
      expect(state.autoRefresh, true);
      await cubit.updateAutoRefresh(false);
      expect(state.autoRefresh, false);
      verify((() => settingsService.setBool(
            key: 'autoRefresh',
            value: false,
          ))).called(1);
    });

    test('updateCloseToTray works', () async {
      expect(state.closeToTray, false);
      await cubit.updateCloseToTray(true);
      expect(state.closeToTray, true);
      verify((() => settingsService.setBool(
            key: 'closeToTray',
            value: true,
          ))).called(1);
    });

    test('updateMinimizeWindows works', () async {
      // Default should be true.
      expect(state.minimizeWindows, true);
      await cubit.updateMinimizeWindows(false);
      expect(state.minimizeWindows, false);
      verify(
        () => storageRepository.saveValue(
          key: 'minimizeWindows',
          value: false,
        ),
      ).called(1);
      await cubit.updateMinimizeWindows(true);
      expect(state.minimizeWindows, true);
      verify(
        () => storageRepository.saveValue(
          key: 'minimizeWindows',
          value: true,
        ),
      ).called(1);
    });

    test('updateShowHiddenWindows works', () async {
      expect(state.showHiddenWindows, false);
      await cubit.updateShowHiddenWindows(true);
      expect(state.showHiddenWindows, true);
      verify((() => settingsService.setBool(
            key: 'showHiddenWindows',
            value: true,
          ))).called(1);
    });

    test('updateStartHiddenInTray works', () async {
      expect(state.startHiddenInTray, false);
      await cubit.updateStartHiddenInTray(true);
      expect(state.startHiddenInTray, true);
      verify((() => settingsService.setBool(
            key: 'startHiddenInTray',
            value: true,
          ))).called(1);
    });

    group('autostart:', () {
      test('disabled by default', () {
        expect(state.autoStart, false);
      });

      test('updating saves preference to storage', () async {
        expect(state.autoStart, false);
        await cubit.updateAutoStart(true);
        expect(state.autoStart, true);
        verify(() => settingsService.setBool(key: 'autoStart', value: true))
            .called(1);
        await cubit.updateAutoStart(false);
        expect(state.autoStart, false);
        verify(() => settingsService.setBool(key: 'autoStart', value: false))
            .called(1);
      });
    });

    group('hotkey:', () {
      test('default hotkey is Pause', () {
        expect(state.hotKey.keyCode, KeyCode.pause);
        expect(state.hotKey.modifiers, null);
      });

      test('removeHotkey works', () async {
        await cubit.removeHotkey();
        verify(() => hotkeyService.removeHotkey()).called(1);
      });

      test('resetting hotkey restores Pause default', () async {
        await cubit.updateHotkey(HotKey(KeyCode.insert));
        expect(state.hotKey.keyCode, KeyCode.insert);
        await cubit.resetHotkey();
        expect(state.hotKey.keyCode, KeyCode.pause);
        verify(() => settingsService.remove('hotkey')).called(1);
      });

      test('saved hotkey is loaded', () async {
        when(() => settingsService.getString('hotkey')).thenReturn(
          '{"keyCode":"insert","modifiers":[],"identifier":"7fe60a47-35b9-4d40-8f74-ec77b83687b3","scope":"system"}',
        );
        cubit = await SettingsCubit.init(
          desktopIntegration: FakeDesktopIntegration(),
          getWindowInfo: getWindowInfo,
          prefs: settingsService,
          hotkeyService: hotkeyService,
          nyrnaWindow: nyrnaWindow,
          storageRepository: storageRepository,
        );
        expect(state.hotKey.keyCode, KeyCode.insert);
        expect(state.hotKey.modifiers?.isEmpty, true);
      });

      test('updateHotkey & resetHotkey work', () async {
        final newHotkey = HotKey(KeyCode.f12);
        expect(state.hotKey.keyCode, KeyCode.pause);
        await cubit.updateHotkey(newHotkey);
        expect(state.hotKey.keyCode, KeyCode.f12);
        verify(() => hotkeyService.updateHotkey(newHotkey)).called(1);
        await cubit.resetHotkey();
        expect(state.hotKey.keyCode, KeyCode.pause);
        verify(() => settingsService.remove('hotkey')).called(1);
      });
    });
    test('saveWindowSize works', () async {
      await cubit.saveWindowSize();
      verify(() => settingsService.setString(
            key: 'windowSize',
            value: fallbackPlatformWindow.frame.toJson(),
          )).called(1);
    });

    test('savedWindowSize works', () async {
      when(() => settingsService.getString('windowSize')).thenReturn(
        fallbackPlatformWindow.frame.toJson(),
      );
      final rect = await cubit.savedWindowSize();
      expect(rect, fallbackPlatformWindow.frame);
    });
  });
}
