import 'dart:async';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:native_platform/native_platform.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/app_version/app_version.dart';
import '../../../infrastructure/preferences/preferences.dart';
import '../../preferences/cubit/preferences_cubit.dart';

part 'app_state.dart';

/// Convenience access to the main app cubit.
late AppCubit appCubit;

class AppCubit extends Cubit<AppState> {
  final NativePlatform _nativePlatform;
  final Preferences _prefs;
  final PreferencesCubit _prefsCubit;
  final AppVersion _appVersion;

  AppCubit({
    required NativePlatform nativePlatform,
    required Preferences prefs,
    required PreferencesCubit prefsCubit,
    required AppVersion appVersion,
    bool testing = false,
  })  : _nativePlatform = nativePlatform,
        _prefs = prefs,
        _prefsCubit = prefsCubit,
        _appVersion = appVersion,
        super(AppState.initial()) {
    appCubit = this;
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchWindows();
    emit(state.copyWith(loading: false));
    setAutoRefresh(
      autoRefresh: _prefsCubit.state.autoRefresh,
      refreshInterval: _prefsCubit.state.refreshInterval,
    );
    await fetchVersionData();
  }

  /// Populate the list of visible windows.
  Future<void> _fetchWindows() async {
    var windows = await _nativePlatform.windows(
      showHidden: _prefsCubit.state.showHiddenWindows,
    );

    for (var window in windows) {
      await window.process.refreshStatus();
    }

    windows.sortWindows();

    emit(state.copyWith(windows: windows));
  }

  Timer? _timer;

  /// The timer which auto-refreshes the list of open windows.
  ///
  /// [refreshInterval] is how often to refresh data, in seconds.
  void setAutoRefresh({
    required bool autoRefresh,
    required int refreshInterval,
  }) {
    if (_timer != null) _timer?.cancel();
    if (autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: refreshInterval),
        (timer) => _fetchWindows(),
      );
    }
  }

  /// Fetch version data so we can notify user of updates.
  @visibleForTesting
  Future<void> fetchVersionData() async {
    final runningVersion = _appVersion.running();
    final latestVersion = await _appVersion.latest();
    final ignoredUpdate = _prefs.getString('ignoredUpdate');
    final updateHasBeenIgnored = (latestVersion == ignoredUpdate);
    final updateAvailable =
        (updateHasBeenIgnored) ? false : await _appVersion.updateAvailable();
    emit(state.copyWith(
      runningVersion: runningVersion,
      updateVersion: latestVersion,
      updateAvailable: updateAvailable,
    ));
  }

  Future<void> manualRefresh() async {
    emit(state.copyWith(loading: true));
    await _fetchWindows();
    emit(state.copyWith(loading: false));
  }

  /// Toggle suspend / resume for the process associated with the given window.
  Future<bool> toggle(Window window) async {
    await window.process.refreshStatus();
    bool successful;

    if (window.process.status == ProcessStatus.suspended) {
      successful = await _resume(window);
    } else {
      successful = await _suspend(window);
    }

    final windows = state.windows;
    await windows
        .singleWhereOrNull((element) => element.id == window.id)
        ?.process
        .refreshStatus();

    emit(state.copyWith(
      windows: windows,
      interactionError: (successful) ? null : InteractionError(window: window),
    ));

    emit(state.copyWith(interactionError: null));

    return successful;
  }

  Future<bool> _resume(Window window) async {
    final successful = await window.process.resume();

    // Restore the window _after_ resuming or it might not restore.
    if (successful) await _nativePlatform.restoreWindow(window.id);

    return successful;
  }

  Future<bool> _suspend(Window window) async {
    // Minimize the window before suspending or it might not minimize.
    await _nativePlatform.minimizeWindow(window.id);

    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final successful = await window.process.suspend();

    // If suspend failed, restore the window so the user won't mistakenly
    // think that the suspend was successful.
    if (!successful) await _nativePlatform.restoreWindow(window.id);

    return successful;
  }

  /// Launch the requested [url] in the default browser.
  Future<void> launchURL(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : throw 'Could not launch url: $url';
  }
}

extension on List<Window> {
  /// Sort the windows by executable name.
  void sortWindows() {
    sortBy((window) => window.process.executable.toLowerCase());
  }
}
