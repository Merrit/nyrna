part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool autoStartHotkey;

  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// Whether the app should continue running in the tray when closed.
  final bool closeToTray;

  /// The hotkey to toggle active application suspend.
  final HotKey hotKey;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  final bool showHiddenWindows;

  final Color trayIconColor;

  const SettingsState({
    required this.autoStartHotkey,
    required this.autoRefresh,
    required this.closeToTray,
    required this.hotKey,
    required this.refreshInterval,
    required this.showHiddenWindows,
    required this.trayIconColor,
  });

  @override
  List<Object> get props {
    return [
      autoStartHotkey,
      autoRefresh,
      closeToTray,
      hotKey,
      refreshInterval,
      showHiddenWindows,
      trayIconColor,
    ];
  }

  SettingsState copyWith({
    bool? autoStartHotkey,
    bool? autoRefresh,
    bool? closeToTray,
    HotKey? hotKey,
    int? refreshInterval,
    bool? showHiddenWindows,
    Color? trayIconColor,
  }) {
    return SettingsState(
      autoStartHotkey: autoStartHotkey ?? this.autoStartHotkey,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      closeToTray: closeToTray ?? this.closeToTray,
      hotKey: hotKey ?? this.hotKey,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      showHiddenWindows: showHiddenWindows ?? this.showHiddenWindows,
      trayIconColor: trayIconColor ?? this.trayIconColor,
    );
  }
}
