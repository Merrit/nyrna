part of 'preferences_cubit.dart';

class PreferencesState extends Equatable {
  /// Whether or not to automatically refresh the list of open windows.
  final bool autoRefresh;

  /// How often to automatically refresh the list of open windows, in seconds.
  final int refreshInterval;

  const PreferencesState({
    required this.autoRefresh,
    required this.refreshInterval,
  });

  @override
  List<Object> get props => [autoRefresh, refreshInterval];

  PreferencesState copyWith({
    bool? autoRefresh,
    bool? isPortable,
    int? refreshInterval,
  }) {
    return PreferencesState(
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }
}
