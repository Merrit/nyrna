import 'dart:async';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/infrastructure/versions/versions.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_state.dart';

/// Convenience access to the main app cubit.
late AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  final NativePlatform nativePlatform;
  final Preferences prefs;

  AppCubit()
      : nativePlatform = NativePlatform(),
        prefs = Preferences.instance,
        super(AppState.initial()) {
    appCubit = this;
    _initialize();
  }

  Future<void> _initialize() async {
    _setAutoRefresh();
    await _fetchDesktop();
    await _fetchVersionData();
  }

  Timer? _timer;

  /// The timer which auto-refreshes the list of open windows.
  void _setAutoRefresh() {
    fetchData();
    if (_timer != null) _timer!.cancel();
    if (prefs.autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: prefs.refreshInterval),
        (timer) => fetchData(),
      );
    }
  }

  Future<void> fetchData() async {
    await _fetchDesktop();
    await fetchWindows();
  }

  Future<void> _fetchDesktop() async {
    final currentDesktop = await nativePlatform.currentDesktop;
    emit(state.copyWith(currentDesktop: currentDesktop));
  }

  Future<void> updateAutoRefresh([bool? autoEnabled]) async {
    if (autoEnabled != null) await prefs.setAutoRefresh(autoEnabled);
    _setAutoRefresh();
  }

  /// Check for which windows are open.
  Future<void> fetchWindows() async {
    final newWindows = await nativePlatform.windows;
    final windows = Map<String, Window>.from(state.windows);
    // Remove if window no longer present, or title has changed.
    windows.removeWhere((pid, window) {
      if (!newWindows.containsKey(pid) || // Window no longer present.
          (newWindows[pid]!.title != window.title)) // Window title changed.
      {
        return true;
      } else {
        return false;
      }
    });
    // Filter out Nyrna's own window / process.
    newWindows.removeWhere((pid, window) => pid == io.pid.toString());
    // Add new windows (and those whose title changed).
    newWindows.forEach((pid, window) {
      if (!windows.containsKey(pid)) windows[pid] = window;
    });
    emit(state.copyWith(windows: windows));
  }

  Future<void> _fetchVersionData() async {
    final versionRepo = Versions();
    final runningVersion = await versionRepo.runningVersion();
    final latestVersion = await versionRepo.latestVersion();
    final ignoredUpdate = Preferences.instance.getString('ignoredUpdate');
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
