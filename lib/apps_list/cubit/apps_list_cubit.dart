import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../active_window/active_window.dart';
import '../../app_version/app_version.dart';
import '../../hotkey/global/hotkey_service.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';
import '../../system_tray/system_tray.dart';
import '../../window/app_window.dart';
import '../apps_list.dart';

part 'apps_list_state.dart';
part 'apps_list_cubit.freezed.dart';

class AppsListCubit extends Cubit<AppsListState> {
  final AppWindow _appWindow;
  final HotkeyService _hotkeyService;
  final NativePlatform _nativePlatform;
  final ProcessRepository _processRepository;
  final SettingsCubit _settingsCubit;
  final StorageRepository _storage;
  final SystemTrayManager _systemTrayManager;
  final AppVersion _appVersion;

  AppsListCubit({
    required AppWindow appWindow,
    required HotkeyService hotkeyService,
    required NativePlatform nativePlatform,
    required ProcessRepository processRepository,
    required SettingsCubit settingsCubit,
    required StorageRepository storage,
    required SystemTrayManager systemTrayManager,
    required AppVersion appVersion,
    bool testing = false,
  })  : _appWindow = appWindow,
        _hotkeyService = hotkeyService,
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
    List<Window> windows = await _nativePlatform.windows(
      showHidden: _settingsCubit.state.showHiddenWindows,
    );

    // Filter out windows that are likely not desired or workable,
    // for example the root window, unknown (0) pid, etc.
    windows.removeWhere((element) => element.process.pid < 10);

    // Update windows with favorite data.
    windows = await _windowsWithFavoriteData(windows);

    for (var i = 0; i < windows.length; i++) {
      windows[i] = await _refreshWindowProcess(windows[i]);
    }

    windows.sortWindows(_settingsCubit.state.pinSuspendedWindows);

    emit(state.copyWith(windows: windows));
  }

  /// Updates the list of windows with favorite data.
  ///
  /// This method takes a list of windows and retrieves the favorite data for
  /// each window from local storage.
  ///
  /// A window is considered a favorite if its executable name has been saved
  /// to the 'favorites' key in local storage.
  Future<List<Window>> _windowsWithFavoriteData(List<Window> windows) async {
    final List<String> favorites = await _storage.getValue('favorites') ?? [];

    return windows.map((window) {
      final isFavorite = favorites.contains(window.process.executable);
      return window.copyWith(
        process: window.process.copyWith(isFavorite: isFavorite),
      );
    }).toList();
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

  /// Set a window as a favorite or not.
  Future<void> setFavorite(Window window, bool favorite) async {
    final List<String> favorites = await _storage.getValue('favorites') ?? [];

    if (favorite) {
      assert(!favorites.contains(window.process.executable));
      favorites.add(window.process.executable);
    } else {
      favorites.remove(window.process.executable);
    }

    await _storage.saveValue(key: 'favorites', value: favorites);
    await manualRefresh();
  }

  /// Set a filter for the windows shown in the list.
  Future<void> setWindowFilter(String pattern) async {
    emit(state.copyWith(windowFilter: pattern.toLowerCase()));
  }

  /// Toggle suspend / resume for the process associated with the given window.
  Future<bool> toggle(Window window) async {
    window = await _refreshWindowProcess(window);
    bool successful;

    final interaction = (window.process.status == ProcessStatus.suspended)
        ? InteractionType.resume
        : InteractionType.suspend;

    log.i('Beginning ${interaction.name} for window: $window');

    if (interaction == InteractionType.resume) {
      successful = await _resume(window);
    } else {
      successful = await _suspend(window);
    }

    log.i('${interaction.name} was successful: $successful');
    window = await _refreshWindowProcess(window);
    log.i('Window after interaction: $window');

    if (!successful) await addInteractionError(window, interaction);

    // Create a copy of the state of windows, with this window's info refreshed.
    final windows = [...state.windows];
    final index = windows.indexWhere((element) => element.id == window.id);
    windows.replaceRange(
      index,
      index + 1,
      [window],
    );

    windows.sortWindows(_settingsCubit.state.pinSuspendedWindows);

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
      _appWindow,
      _nativePlatform,
      _processRepository,
      _storage,
    );

    await _nativePlatform.checkActiveWindow();
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
        log.i('Triggering toggle from hotkey press.');
        await toggleActiveWindow();
      } else {
        final appSpecificHotkey = _settingsCubit.state.appSpecificHotKeys
            .firstWhereOrNull((e) => e.hotkey == hotkey);
        if (appSpecificHotkey == null) return;

        log.i('Triggering toggle from app-specific hotkey press.\n'
            'Hotkey: $hotkey\n'
            'Executable: ${appSpecificHotkey.executable}');
        await toggleExecutable(appSpecificHotkey.executable);
      }
    });
  }

  /// After the window is shown via the system tray, refresh the list of windows.
  void _listenForSystemTrayShowEvent() {
    _systemTrayManager.eventStream.listen((event) async {
      if (event == SystemTrayEvent.windowShow) {
        await manualRefresh();
      }
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
  ///
  /// Visible so it can be used by the debug menu.
  @visibleForTesting
  Future<void> addInteractionError(
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

  /// Clear all interaction errors.
  void clearInteractionErrors() {
    emit(state.copyWith(
      interactionErrors: [],
    ));
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
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
  ///
  /// If the user has enabled pinning suspended windows to the top of the list,
  /// or the window's process has been favorited by the user, those windows will
  /// be sorted to the top.
  void sortWindows(bool pinSuspendedWindows) {
    sort((a, b) {
      final aIsSuspended = a.process.status == ProcessStatus.suspended;
      final bIsSuspended = b.process.status == ProcessStatus.suspended;

      final aIsFavorite = a.process.isFavorite;
      final bIsFavorite = b.process.isFavorite;

      if (pinSuspendedWindows) {
        if (aIsSuspended && !bIsSuspended) return -1;
        if (!aIsSuspended && bIsSuspended) return 1;
      }

      if (aIsFavorite && !bIsFavorite) return -1;
      if (!aIsFavorite && bIsFavorite) return 1;

      return a.process.executable.toLowerCase().compareTo(
            b.process.executable.toLowerCase(),
          );
    });
  }
}
