part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    /// Message for the user if they are running Nyrna on Wayland, or if their
    /// session type is unknown.
    String? linuxSessionMessage,

    /// The type of desktop session the user is running.
    ///
    /// Currently only used on Linux.
    SessionType? sessionType,

    /// True if this is the first run of the app.
    required bool firstRun,
    required String runningVersion,
    required String? updateVersion,
    required bool updateAvailable,
    required bool showUpdateButton,

    /// Release notes for the current version.
    required ReleaseNotes? releaseNotes,
  }) = _AppState;

  factory AppState.initial() {
    return const AppState(
      firstRun: false,
      runningVersion: '',
      updateVersion: null,
      updateAvailable: false,
      showUpdateButton: false,
      releaseNotes: null,
    );
  }
}
