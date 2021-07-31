import 'dart:async';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/domain/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/infrastructure/versions/versions.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_state.dart';

/// Convenience access to the main app cubit.
late AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  final NativePlatform _nativePlatform;
  final Preferences _prefs;

  AppCubit({
    required NativePlatform nativePlatform,
    required Preferences prefs,
  })  : _nativePlatform = nativePlatform,
        _prefs = prefs,
        super(AppState.initial()) {
    appCubit = this;
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkIsPortable();
    setAutoRefresh(
      autoRefresh: preferencesCubit.state.autoRefresh,
      refreshInterval: preferencesCubit.state.refreshInterval,
    );
    await _fetchDesktop();
    await _fetchVersionData();
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
    fetchData();
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
    final currentDesktop = await _nativePlatform.currentDesktop;
    emit(state.copyWith(currentDesktop: currentDesktop));
  }

  /// Populate the list of visible windows.
  Future<void> _fetchWindows() async {
    final windows = await _nativePlatform.windows();
    await Future.forEach<Window>(windows, (window) async {
      final process = await _nativePlatform.windowProcess(window.id);
      window.process = process;
    });
    windows.removeWhere(
      (window) => _filteredWindows.contains(window.process!.executable),
    );
    emit(state.copyWith(windows: windows));
  }

  Future<void> _fetchVersionData() async {
    final versionRepo = Versions();
    final runningVersion = await versionRepo.runningVersion();
    final latestVersion = await versionRepo.latestVersion();
    final ignoredUpdate = _prefs.getString('ignoredUpdate');
    final updateHasBeenIgnored = (latestVersion == ignoredUpdate);
    final updateAvailable =
        (updateHasBeenIgnored) ? false : await versionRepo.updateAvailable();
    emit(state.copyWith(
      runningVersion: runningVersion,
      updateVersion: latestVersion,
      updateAvailable: updateAvailable,
    ));
  }

  Future<void> launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }
}

/// System-level or non-app executables. Nyrna shouldn't show these.
List<String> _filteredWindows = [
  'nyrna.exe',
  'ApplicationFrameHost.exe', // Manages UWP (Universal Windows Platform) apps
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
