part of 'preferences_cubit.dart';

class PreferencesState extends Equatable {
  final bool autoStartHotkey;

  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  final Color trayIconColor;

  const PreferencesState({
    required this.autoStartHotkey,
    required this.autoRefresh,
    required this.refreshInterval,
    required this.trayIconColor,
  });

  @override
  List<Object> get props =>
      [autoStartHotkey, autoRefresh, refreshInterval, trayIconColor];

  PreferencesState copyWith({
    bool? autoStartHotkey,
    bool? autoRefresh,
    int? refreshInterval,
    Color? trayIconColor,
  }) {
    return PreferencesState(
      autoStartHotkey: autoStartHotkey ?? this.autoStartHotkey,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      trayIconColor: trayIconColor ?? this.trayIconColor,
    );
  }
}
