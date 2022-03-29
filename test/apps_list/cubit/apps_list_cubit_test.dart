import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:native_platform/native_platform.dart';
import 'package:nyrna/apps_list/apps_list.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:test/test.dart';

import '../../mock_app_version.dart';
import '../../mock_native_platform.dart';
import '../../mock_process.dart';
import '../../mock_settings_cubit.dart';
import '../../mock_settings_service.dart';

final msPaintProcess = MockProcess(
  executable: 'mspaint.exe',
  pid: 3716,
);

final msPaintWindow = Window(
  id: 132334,
  process: msPaintProcess,
  title: 'Untitled - Paint',
);

void main() {
  group('AppCubit:', () {
    final _nativePlatform = MockNativePlatform();
    final _prefs = MockSettingsService();
    final _prefsCubit = MockSettingsCubit();
    final _appVersion = MockAppVersion();

    late AppsListCubit _appCubit;

    when(() => _prefs.getString('ignoredUpdate')).thenReturn(null);

    when(() => _prefsCubit.state).thenReturn(
      const SettingsState(
        autoStartHotkey: false,
        autoRefresh: false,
        refreshInterval: 5,
        showHiddenWindows: false,
        trayIconColor: Colors.blue,
      ),
    );

    when(() => _nativePlatform.windows(showHidden: any(named: 'showHidden')))
        .thenAnswer((_) async => []);

    setUp(() {
      when(() => _appVersion.latest()).thenAnswer((_) async => '1.0.0');
      when(() => _appVersion.updateAvailable()).thenAnswer((_) async => false);

      _appCubit = AppsListCubit(
        nativePlatform: _nativePlatform,
        prefs: _prefs,
        prefsCubit: _prefsCubit,
        appVersion: _appVersion,
        testing: true,
      );
    });

    test('initial state has no windows', () {
      expect(_appCubit.state.windows.length, 0);
    });

    test('new window is added to state', () async {
      expect(_appCubit.state.windows.length, 0);

      when(() => _nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);

      await _appCubit.manualRefresh();
      expect(_appCubit.state.windows.length, 1);
    });

    test('process changed externally updates state', () async {
      when(() => _nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [msPaintWindow]);
      when(() => msPaintProcess.status).thenReturn(ProcessStatus.normal);

      await _appCubit.manualRefresh();

      // Verify we have one window, and it has a normal status.
      var windows = _appCubit.state.windows;
      expect(windows.length, 1);
      expect(windows[0].process.status, ProcessStatus.normal);

      // Simulate the process being suspended outside Nyrna.
      when(() => msPaintProcess.status).thenReturn(ProcessStatus.suspended);

      // Verify we pick up this status change.
      await _appCubit.manualRefresh();
      windows = _appCubit.state.windows;
      expect(windows.length, 1);
      expect(windows[0].process.status, ProcessStatus.suspended);
    });

    test('app version information populates to cubit', () async {
      // Verify initial state is unpopulated.
      expect(_appCubit.state.runningVersion, '');
      expect(_appCubit.state.updateVersion, '');
      expect(_appCubit.state.updateAvailable, false);

      // Stubbed data propogates.
      await _appCubit.fetchVersionData();
      expect(_appCubit.state.runningVersion, '1.0.0');
      expect(_appCubit.state.updateVersion, '1.0.0');
      expect(_appCubit.state.updateAvailable, false);

      // Simulate an update being available.
      when(() => _appVersion.latest()).thenAnswer((_) async => '1.0.1');
      when(() => _appVersion.updateAvailable()).thenAnswer((_) async => true);
      await _appCubit.fetchVersionData();
      expect(_appCubit.state.runningVersion, '1.0.0');
      expect(_appCubit.state.updateVersion, '1.0.1');
      expect(_appCubit.state.updateAvailable, true);
    });

    test('windows are sorted', () async {
      when(() => _nativePlatform.windows(showHidden: any(named: 'showHidden')))
          .thenAnswer((_) async => [
                Window(
                  id: 7363,
                  process: MockProcess(executable: 'kate', pid: 836482),
                  title: 'Kate',
                ),
                Window(
                  id: 29347,
                  process: MockProcess(executable: 'evince', pid: 94847),
                  title: 'Evince',
                ),
                Window(
                  id: 89374,
                  process: MockProcess(executable: 'ark', pid: 9374623),
                  title: 'Ark',
                ),
              ]);

      await _appCubit.manualRefresh();
      final windows = _appCubit.state.windows;
      expect(windows[0].process.executable, 'ark');
      expect(windows[1].process.executable, 'evince');
      expect(windows[2].process.executable, 'kate');
    });
  });
}
