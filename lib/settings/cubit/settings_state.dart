part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// A list of configured app-specific hotkeys.
    required List<AppSpecificHotkey> appSpecificHotKeys,

    /// True if the app should be automatically started on login.
    ///
    /// This is only used on desktop platforms.
    required bool autoStart,

    /// Whether or not to automatically refresh the list of open windows.
    required bool autoRefresh,

    /// Whether the app should continue running in the tray when closed.
    required bool closeToTray,

    /// The hotkey to toggle active application suspend.
    required HotKey hotKey,

    /// If true the window will be automatically minimized when suspending and
    /// restored when resuming.
    required bool minimizeWindows,

    /// How often to automatically refresh the list of open windows, in seconds.
    required int refreshInterval,
    required bool showHiddenWindows,
    required bool startHiddenInTray,

    /// True if the app is currently working on something and a loading
    /// indicator should be shown.
    required bool working,
  }) = _SettingsState;

  factory SettingsState.initial() => SettingsState(
        appSpecificHotKeys: [],
        autoStart: false,
        autoRefresh: true,
        closeToTray: false,
        hotKey: defaultHotkey,
        minimizeWindows: true,
        refreshInterval: 5,
        showHiddenWindows: false,
        startHiddenInTray: false,
        working: false,
      );
}
