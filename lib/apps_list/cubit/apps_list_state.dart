part of 'apps_list_cubit.dart';

class AppsListState extends Equatable {
  /// True when the app should communicate when work is being done,
  /// such as when the user requests a manual refresh.
  final bool loading;

  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;

  /// Contains [InteractionError]s for any window that had an error.
  final List<InteractionError> interactionErrors;

  final List<Window> windows;

  /// Non-null if interacting with a process failed.

  const AppsListState({
    required this.loading,
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.interactionErrors,
    required this.windows,
  });

  factory AppsListState.initial() {
    return const AppsListState(
      loading: true,
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      interactionErrors: [],
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
      interactionErrors,
      windows,
    ];
  }

  AppsListState copyWith({
    bool? loading,
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    List<InteractionError>? interactionErrors,
    List<Window>? windows,
  }) {
    return AppsListState(
      loading: loading ?? this.loading,
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      interactionErrors: interactionErrors ?? this.interactionErrors,
      windows: windows ?? this.windows,
    );
  }
}
