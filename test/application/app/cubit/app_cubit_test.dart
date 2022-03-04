import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:native_platform/native_platform.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/infrastructure/versions/versions.dart';

class MockPreferences extends Mock implements Preferences {}

class MockPreferencesCubit extends Mock implements PreferencesCubit {
  MockPreferencesCubit()
      : _state = PreferencesState(
          autoRefresh: false,
          autoStartHotkey: false,
          refreshInterval: 5,
          showHiddenWindows: false,
          trayIconColor: Colors.amber,
        );

  final PreferencesState _state;

  @override
  PreferencesState get state => _state;
}

class MockPrefsCubitState extends Mock implements PreferencesState {}

class MockNativePlatform extends Mock implements NativePlatform {
  @override
  Future<int> currentDesktop() async => 0;

  /// Mocks aren't working, this allows us to mock manually. 🤷‍♀️
  List<Window> mockWindows = [];

  @override
  Future<List<Window>> windows({required bool showHidden}) async => mockWindows;
}

class MockWindow extends Mock implements Window {
  @override
  final MockProcess process;

  MockWindow({
    required int id,
    required this.process,
    required String title,
  });
}

class MockProcess extends Mock implements Process {
  MockProcess({required String executable, required int pid})
      : _executable = executable,
        _pid = pid;

  final String _executable;

  @override
  String get executable => _executable;

  final int _pid;

  @override
  int get pid => _pid;

  @override
  ProcessStatus status = ProcessStatus.normal;
}

class MockVersions implements Versions {
  @override
  Future<String> latestVersion() async => '2.3.0';

  @override
  Future<String> runningVersion() async => '2.3.0';

  @override
  Future<bool> updateAvailable() async => false;
}

final msPaintWindow = MockWindow(
  id: 132334,
  process: MockProcess(
    executable: 'mspaint.exe',
    pid: 3716,
  ),
  title: 'Untitled - Paint',
);

void main() {
  group('AppCubit:', () {
    final _nativePlatform = MockNativePlatform();
    final _prefs = MockPreferences();
    final _prefsCubit = MockPreferencesCubit();
    final _versions = MockVersions();

    late AppCubit _appCubit;

    setUp(() {
      _appCubit = AppCubit(
        nativePlatform: _nativePlatform,
        prefs: _prefs,
        prefsCubit: _prefsCubit,
        versionRepository: _versions,
        testing: true,
      );

      _nativePlatform.mockWindows = [];
    });

    test('Initial state has no windows', () {
      expect(_appCubit.state.windows.length, 0);
    });

    test('New window is added to state', () async {
      final numStartingWindows = _appCubit.state.windows.length;

      _nativePlatform.mockWindows = [msPaintWindow];

      await _appCubit.manualRefresh();
      final numUpdatedWindows = _appCubit.state.windows.length;
      expect(numUpdatedWindows, numStartingWindows + 1);
    });

    test('ProcessStatus changing externally updates state', () async {
      _nativePlatform.mockWindows = [msPaintWindow];

      await _appCubit.manualRefresh();

      // Verify we have one window, and it has a normal status.
      var windows = _appCubit.state.windows;
      expect(windows.length, 1);
      var window = windows[0];
      expect(window.process.status, ProcessStatus.normal);

      // Simulate the process being suspended outside Nyrna.
      final updatedWindow = msPaintWindow;
      updatedWindow.process.status = ProcessStatus.suspended;
      _nativePlatform.mockWindows = [updatedWindow];

      // Verify we pick up this status change.
      await _appCubit.manualRefresh();
      windows = _appCubit.state.windows;
      expect(windows.length, 1);
      window = windows[0];
      expect(window.process.status, ProcessStatus.suspended);
    });
  });
}
