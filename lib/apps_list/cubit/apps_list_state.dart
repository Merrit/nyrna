part of 'apps_list_cubit.dart';

@freezed
abstract class AppsListState with _$AppsListState {
  const factory AppsListState({
    /// True when the app should communicate when work is being done,
    /// such as when the user requests a manual refresh.
    required bool loading,
    required String runningVersion,
    required String updateVersion,
    required bool updateAvailable,

    /// Contains [InteractionError]s for any window that had an error.
    required List<InteractionError> interactionErrors,
    required List<Window> windows,

    /// Pattern to filter windows by.
    required String windowFilter,
  }) = _AppsListState;

  factory AppsListState.initial() {
    return const AppsListState(
      loading: true,
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      interactionErrors: [],
      windows: <Window>[],
      windowFilter: '',
    );
  }
}
