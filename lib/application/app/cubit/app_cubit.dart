import 'dart:async';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:native_platform/native_platform.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/infrastructure/versions/versions.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_state.dart';

/// Convenience access to the main app cubit.
late AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  final NativePlatform _nativePlatform;
  final Preferences _prefs;
  final PreferencesCubit _prefsCubit;
  final Versions _versionRepo;

  /// Will be true if running under a unit test.
  final bool _testing;

  AppCubit({
    required NativePlatform nativePlatform,
    required Preferences prefs,
    required PreferencesCubit prefsCubit,
    required Versions versionRepository,
    bool testing = false,
  })  : _nativePlatform = nativePlatform,
        _prefs = prefs,
        _prefsCubit = prefsCubit,
        _versionRepo = versionRepository,
        _testing = testing,
        super(AppState.initial()) {
    appCubit = this;
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchData();
    emit(state.copyWith(loading: false));
    await _checkIsPortable();
    setAutoRefresh(
      autoRefresh: _prefsCubit.state.autoRefresh,
      refreshInterval: _prefsCubit.state.refreshInterval,
    );
    await fetchVersionData();
  }

  Future<void> _checkIsPortable() async {
    final file = io.File('PORTABLE');
    final isPortable = await file.exists();
    emit(state.copyWith(isPortable: isPortable));
  }

  Timer? _timer;

  /// The timer which auto-refreshes the list of open windows.
  void setAutoRefresh({
    required bool autoRefresh,
    required int refreshInterval,
  }) {
    if (_timer != null) _timer?.cancel();
    if (autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: refreshInterval),
        (timer) => fetchData(),
      );
    }
  }

  Future<void> fetchData() async {
    await _fetchDesktop();
    await _fetchWindows();
  }

  Future<void> _fetchDesktop() async {
    final currentDesktop = await _nativePlatform.currentDesktop();
    emit(state.copyWith(currentDesktop: currentDesktop));
  }

  List<Window> _sortWindows(List<Window> windows) {
    return windows.sortedBy(
      (window) => window.process.executable.toLowerCase(),
    );
  }

  /// Populate the list of visible windows.
  Future<void> _fetchWindows() async {
    final showHidden = _prefsCubit.state.showHiddenWindows;
    var windows = await _nativePlatform.windows(showHidden: showHidden);
    windows.removeWhere(
      (window) => _filteredWindows.contains(window.process.executable),
    );
    windows = await _checkWindowStatuses(windows);
    final sortedWindows = _sortWindows(windows);
    emit(state.copyWith(windows: sortedWindows));
  }

  /// Update the ProcessStatus for the given [windows].
  Future<List<Window>> _checkWindowStatuses(List<Window> windows) async {
    if (_testing) return windows;
    final processedWindows = <Window>[];
    for (var window in windows) {
      await window.process.refreshStatus();
      processedWindows.add(window);
    }
    return processedWindows;
  }

  Future<void> manualRefresh() async {
    emit(state.copyWith(loading: true));
    await fetchData();
    emit(state.copyWith(loading: false));
  }

  @visibleForTesting
  Future<void> fetchVersionData() async {
    final runningVersion = await _versionRepo.runningVersion();
    final latestVersion = await _versionRepo.latestVersion();
    final ignoredUpdate = _prefs.getString('ignoredUpdate');
    final updateHasBeenIgnored = (latestVersion == ignoredUpdate);
    final updateAvailable =
        (updateHasBeenIgnored) ? false : await _versionRepo.updateAvailable();
    emit(state.copyWith(
      runningVersion: runningVersion,
      updateVersion: latestVersion,
      updateAvailable: updateAvailable,
    ));
  }

  /// Toggle suspend / resume for the process associated with the given window.
  Future<bool> toggle(Window window) async {
    ProcessStatus status = await window.process.refreshStatus();
    bool success;
    if (status == ProcessStatus.suspended) {
      success = await _resume(window);
      status = await window.process.refreshStatus();
      if (status != ProcessStatus.normal) success = false;
    } else {
      success = await _suspend(window);
      status = await window.process.refreshStatus();
      if (status != ProcessStatus.suspended) success = false;
    }
    final windows = List<Window>.from(state.windows);
    windows.removeWhere((e) => e.id == window.id);
    windows.add(window);
    final sortedWindows = _sortWindows(windows);
    emit(state.copyWith(windows: sortedWindows));
    return success;
  }

  Future<bool> _resume(Window window) async {
    final success = await window.process.resume();
    // Restore the window _after_ resuming or it might not restore.
    if (success) await _nativePlatform.restoreWindow(window.id);
    return success;
  }

  Future<bool> _suspend(Window window) async {
    // Minimize the window before suspending or it might not minimize.
    await _nativePlatform.minimizeWindow(window.id);
    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    final successful = await window.process.suspend();
    if (!successful) {
      await _nativePlatform.restoreWindow(window.id);
    }
    return successful;
  }

  Future<void> launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }
}

/// System-level or non-app executables. Nyrna shouldn't show these.
List<String> _filteredWindows = [
  'nyrna',
  'nyrna.exe',
  'ApplicationFrameHost.exe', // Manages UWP (Universal Windows Platform) apps
  'dwm.exe', // Win32's compositing window manager
  'explorer.exe', // Windows File Explorer
  'googledrivesync.exe',
  'LogiOverlay.exe', // Logitech Options
  'PenTablet.exe', // XP-PEN driver
  'perfmon.exe', // Resource Monitor
  'Rainmeter.exe',
  'SystemSettings.exe', // Windows system settings
  'Taskmgr.exe', // Windows Task Manager
  'TextInputHost.exe', // Microsoft Text Input Application
  'WinStore.App.exe', // Windows Store
];
