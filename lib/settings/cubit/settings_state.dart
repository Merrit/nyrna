part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
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
  }) = _SettingsState;
}
