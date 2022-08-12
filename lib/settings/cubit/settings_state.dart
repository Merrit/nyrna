part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool autoStart;

  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// Whether the app should continue running in the tray when closed.
  final bool closeToTray;

  /// The hotkey to toggle active application suspend.
  final HotKey hotKey;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  final bool showHiddenWindows;
  final bool startHiddenInTray;

  const SettingsState({
    required this.autoStart,
    required this.autoRefresh,
    required this.closeToTray,
    required this.hotKey,
    required this.refreshInterval,
    required this.showHiddenWindows,
    required this.startHiddenInTray,
  });

  @override
  List<Object> get props {
    return [
      autoStart,
      autoRefresh,
      closeToTray,
      hotKey,
      refreshInterval,
      showHiddenWindows,
      startHiddenInTray,
    ];
  }

  SettingsState copyWith({
    bool? autoStart,
    bool? autoRefresh,
    bool? closeToTray,
    HotKey? hotKey,
    int? refreshInterval,
    bool? showHiddenWindows,
    bool? startHiddenInTray,
  }) {
    return SettingsState(
      autoStart: autoStart ?? this.autoStart,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      closeToTray: closeToTray ?? this.closeToTray,
      hotKey: hotKey ?? this.hotKey,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      showHiddenWindows: showHiddenWindows ?? this.showHiddenWindows,
      startHiddenInTray: startHiddenInTray ?? this.startHiddenInTray,
    );
  }
}
