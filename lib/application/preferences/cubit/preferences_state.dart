part of 'preferences_cubit.dart';

class PreferencesState extends Equatable {
  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  final Color trayIconColor;

  const PreferencesState({
    required this.autoRefresh,
    required this.refreshInterval,
    required this.trayIconColor,
  });

  @override
  List<Object> get props => [autoRefresh, refreshInterval, trayIconColor];

  PreferencesState copyWith({
    bool? autoRefresh,
    int? refreshInterval,
    Color? trayIconColor,
  }) {
    return PreferencesState(
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      trayIconColor: trayIconColor ?? this.trayIconColor,
    );
  }
}
