import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:native_platform/native_platform.dart';
import 'package:test/test.dart';

import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';

import '../../../fake_app_version.dart';
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
    final _versions = FakeAppVersion();

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
      _appCubit = AppCubit(
        nativePlatform: _nativePlatform,
        prefs: _prefs,
        prefsCubit: _prefsCubit,
        versionRepository: _versions,
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
  });
}
