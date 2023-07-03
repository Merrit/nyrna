part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    /// True if this appears to be the app's first run.
    required bool firstRun,
  }) = _AppState;

  factory AppState.initial() => const AppState(
        firstRun: false,
      );
}
