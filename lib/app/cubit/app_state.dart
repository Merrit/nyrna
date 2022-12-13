part of 'app_cubit.dart';

class AppState extends Equatable {
  /// True if this appears to be the app's first run.
  final bool firstRun;

  const AppState({
    required this.firstRun,
  });

  factory AppState.initial() {
    return const AppState(
      firstRun: false,
    );
  }

  @override
  List<Object> get props => [firstRun];

  AppState copyWith({
    bool? firstRun,
  }) {
    return AppState(
      firstRun: firstRun ?? this.firstRun,
    );
  }
}
