part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool autoStartHotkey;

  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  final bool showHiddenWindows;

  final Color trayIconColor;

  const SettingsState({
    required this.autoStartHotkey,
    required this.autoRefresh,
    required this.refreshInterval,
    required this.showHiddenWindows,
    required this.trayIconColor,
  });

  @override
  List<Object> get props {
    return [
      autoStartHotkey,
      autoRefresh,
      refreshInterval,
      showHiddenWindows,
      trayIconColor,
    ];
  }

  SettingsState copyWith({
    bool? autoStartHotkey,
    bool? autoRefresh,
    int? refreshInterval,
    bool? showHiddenWindows,
    Color? trayIconColor,
  }) {
    return SettingsState(
      autoStartHotkey: autoStartHotkey ?? this.autoStartHotkey,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      showHiddenWindows: showHiddenWindows ?? this.showHiddenWindows,
      trayIconColor: trayIconColor ?? this.trayIconColor,
    );
  }
}
