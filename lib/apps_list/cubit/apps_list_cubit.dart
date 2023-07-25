import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../active_window/active_window.dart';
import '../../app_version/app_version.dart';
import '../../hotkey/hotkey_service.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';
import '../../system_tray/system_tray_manager.dart';
import '../apps_list.dart';

part 'apps_list_state.dart';
part 'apps_list_cubit.freezed.dart';

class AppsListCubit extends Cubit<AppsListState> {
  final HotkeyService _hotkeyService;
  final NativePlatform _nativePlatform;
  final ProcessRepository _processRepository;
  final SettingsCubit _settingsCubit;
  final StorageRepository _storage;
  final SystemTrayManager _systemTrayManager;
  final AppVersion _appVersion;

  AppsListCubit({
    required HotkeyService hotkeyService,
    required NativePlatform nativePlatform,
    required ProcessRepository processRepository,
    required SettingsCubit settingsCubit,
    required StorageRepository storage,
    required SystemTrayManager systemTrayManager,
    required AppVersion appVersion,
    bool testing = false,
  })  : _hotkeyService = hotkeyService,
        _nativePlatform = nativePlatform,
        _settingsCubit = settingsCubit,
        _processRepository = processRepository,
        _storage = storage,
        _systemTrayManager = systemTrayManager,
        _appVersion = appVersion,
        super(AppsListState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchWindows();
    emit(state.copyWith(loading: false));
    setAutoRefresh(
      autoRefresh: _settingsCubit.state.autoRefresh,
      refreshInterval: _settingsCubit.state.refreshInterval,
    );
    _listenForHotkey();
    _listenForSystemTrayShowEvent();
    await fetchVersionData();
  }

  /// Populate the list of visible windows.
  Future<void> _fetchWindows() async {
    final windows = await _nativePlatform.windows(
      showHidden: _settingsCubit.state.showHiddenWindows,
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

  /// Toggle suspend/resume for all instances of [executable].
  ///
  /// For example, if called on mpv and there are multiple windows / instances
  /// of the app running, they will all be suspended.
  Future<void> toggleExecutable(String executable) async {
    final matchingWindows = state //
        .windows
        .where((e) => e.process.executable == executable);

    for (var match in matchingWindows) {
      await toggle(match);
    }
  }

  Future<bool> toggleActiveWindow() async {
    final activeWindow = ActiveWindow(
      _nativePlatform,
      _processRepository,
      _storage,
    );

    return await activeWindow.toggle();
  }

  /// Toggle suspend/resume for all instances of [window.process.executable].
  ///
  /// For example, if called on mpv and there are multiple windows / instances
  /// of the app running, they will all be suspended.
  Future<void> toggleAll(Window window) async {
    final matchingWindows = state //
        .windows
        .where((e) =>
            (e.process.executable == window.process.executable) &&
            // Ensure we only perform the intended action. Eg, if we are
            // suspending all but some are already suspended we don't want the
            // already suspended instances to resume.
            (e.process.status == window.process.status));

    for (var match in matchingWindows) {
      await toggle(match);
    }
  }

  /// React when a configured hotkey is pressed.
  void _listenForHotkey() {
    _hotkeyService.hotkeyTriggeredStream.listen((hotkey) async {
      await manualRefresh();

      if (hotkey == _settingsCubit.state.hotKey) {
        log.v('Triggering toggle from hotkey press.');
        await toggleActiveWindow();
      } else {
        final appSpecificHotkey = _settingsCubit.state.appSpecificHotKeys
            .firstWhereOrNull((e) => e.hotkey == hotkey);
        if (appSpecificHotkey == null) return;

        log.v('Triggering toggle from app-specific hotkey press.\n'
            'Hotkey: $hotkey\n'
            'Executable: ${appSpecificHotkey.executable}');
        await toggleExecutable(appSpecificHotkey.executable);
      }
    });
  }

  /// After the window is shown via the system tray, refresh the list of windows.
  void _listenForSystemTrayShowEvent() {
    _systemTrayManager.windowShownStream.listen((_) async {
      await manualRefresh();
    });
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
    if (!_settingsCubit.state.minimizeWindows) return;

    // Minimize the window before suspending or it might not minimize.
    await _nativePlatform.minimizeWindow(window.id);

    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _restore(Window window) async {
    if (!_settingsCubit.state.minimizeWindows) return;

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
