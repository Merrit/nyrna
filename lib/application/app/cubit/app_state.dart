part of 'app_cubit.dart';

class AppState extends Equatable {
  /// True when the app should communicate when work is being done,
  /// such as when the user requests a manual refresh.
  final bool loading;

  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;

  final List<Window> windows;

  /// Non-null if interacting with a process failed.
  final InteractionError? interactionError;

  const AppState({
    required this.loading,
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.windows,
    this.interactionError,
  });

  factory AppState.initial() {
    return const AppState(
      loading: true,
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      windows: <Window>[],
    );
  }

  @override
  List<Object?> get props {
    return [
      loading,
      runningVersion,
      updateVersion,
      updateAvailable,
      windows,
      interactionError,
    ];
  }

  AppState copyWith({
    bool? loading,
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    List<Window>? windows,
    InteractionError? interactionError,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      windows: windows ?? this.windows,
      interactionError: interactionError,
    );
  }
}

/// Present in AppState when an interaction has failed.
class InteractionError {
  final Window window;

  const InteractionError({
    required this.window,
  });
}
