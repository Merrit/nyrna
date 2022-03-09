import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:native_platform/native_platform.dart';
import 'package:test/test.dart';

import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';

import '../../../mock_app_version.dart';
import '../../../mock_native_platform.dart';
import '../../../mock_preferences.dart';
import '../../../mock_preferences_cubit.dart';
import '../../../mock_process.dart';

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
    final _prefs = MockPreferences();
    final _prefsCubit = MockPreferencesCubit();
    final _appVersion = MockAppVersion();

    late AppCubit _appCubit;

    when(() => _prefs.getString('ignoredUpdate')).thenReturn(null);

    when(() => _prefsCubit.state).thenReturn(
      PreferencesState(
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

      _appCubit = AppCubit(
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
  });
}
