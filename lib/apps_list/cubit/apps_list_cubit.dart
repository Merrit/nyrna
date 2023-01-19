import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../app_version/app_version.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';
import '../apps_list.dart';

part 'apps_list_state.dart';

/// Convenience access to the main app cubit.
late AppsListCubit appsListCubit;

class AppsListCubit extends Cubit<AppsListState> {
  final NativePlatform _nativePlatform;
  final SettingsCubit _prefsCubit;
  final ProcessRepository _processRepository;
  final StorageRepository _storage;
  final AppVersion _appVersion;

  AppsListCubit({
    required NativePlatform nativePlatform,
    required SettingsCubit prefsCubit,
    required ProcessRepository processRepository,
    required StorageRepository storage,
    required AppVersion appVersion,
    bool testing = false,
  })  : _nativePlatform = nativePlatform,
        _prefsCubit = prefsCubit,
        _processRepository = processRepository,
        _storage = storage,
        _appVersion = appVersion,
        super(AppsListState.initial()) {
    appsListCubit = this;
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

    // Filter out windows that are likely not desired or workable,
    // for example the root window, unknown (0) pid, etc.
    windows.removeWhere((element) => element.process.pid < 10);

    for (var i = 0; i < windows.length; i++) {
      windows[i] = await _refreshWindowProcess(windows[i]);
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
    final String? ignoredUpdate = await _storage.getValue('ignoredUpdate');
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
    window = await _refreshWindowProcess(window);
    bool successful;

    final interaction = (window.process.status == ProcessStatus.suspended)
        ? InteractionType.resume
        : InteractionType.suspend;

    log.v('Beginning ${interaction.name} for window: $window');

    if (interaction == InteractionType.resume) {
      successful = await _resume(window);
    } else {
      successful = await _suspend(window);
    }

    log.v('${interaction.name} was successful: $successful');
    window = await _refreshWindowProcess(window);
    log.v('Window after interaction: $window');

    if (!successful) await _addInteractionError(window, interaction);

    // Create a copy of the state of windows, with this window's info refreshed.
    final windows = [...state.windows];
    final index = windows.indexWhere((element) => element.id == window.id);
    windows.replaceRange(
      index,
      index + 1,
      [window],
    );

    emit(state.copyWith(
      windows: windows,
    ));

    return successful;
  }

  Future<bool> _resume(Window window) async {
    final successful = await _processRepository.resume(window.process.pid);

    // Restore the window _after_ resuming or it might not restore.
    if (successful) await _restore(window);

    return successful;
  }

  Future<bool> _suspend(Window window) async {
    await _minimize(window);
    final successful = await _processRepository.suspend(window.process.pid);

    // If suspend failed, restore the window so the user won't mistakenly
    // think that the suspend was successful.
    if (!successful) await _restore(window);
    return successful;
  }

  Future<void> _minimize(Window window) async {
    if (!_prefsCubit.state.minimizeWindows) return;

    // Minimize the window before suspending or it might not minimize.
    await _nativePlatform.minimizeWindow(window.id);

    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _restore(Window window) async {
    if (!_prefsCubit.state.minimizeWindows) return;

    await _nativePlatform.restoreWindow(window.id);
  }

  /// Refresh the process status associated with [window].
  Future<Window> _refreshWindowProcess(Window window) async {
    final process = window.process;
    return window.copyWith(
      process: process.copyWith(
        status: await _processRepository.getProcessStatus(process.pid),
      ),
    );
  }

  /// Refresh the process status and add an [InteractionError].
  Future<void> _addInteractionError(
    Window window,
    InteractionType interaction,
  ) async {
    final interactionError = InteractionError(
      interactionType: interaction,
      statusAfterInteraction: window.process.status,
      windowId: window.id,
    );

    final errors = [...state.interactionErrors] //
      ..addError(interactionError);

    emit(state.copyWith(
      interactionErrors: errors,
    ));
  }
}

extension on List<InteractionError> {
  void addError(InteractionError interactionError) {
    removeWhere((e) => e.windowId == interactionError.windowId);
    add(interactionError);
  }
}

extension on List<Window> {
  /// Sort the windows by executable name.
  void sortWindows() {
    sortBy((window) => window.process.executable.toLowerCase());
  }
}
