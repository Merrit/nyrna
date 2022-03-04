part of 'app_cubit.dart';

class AppState extends Equatable {
  final bool loading;

  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;

  /// The index of the currently active virtual desktop.
  final int currentDesktop;

  final List<Window> windows;

  const AppState({
    required this.loading,
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.currentDesktop,
    required this.windows,
  });

  factory AppState.initial() {
    return AppState(
      loading: true,
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
      currentDesktop: 0,
      windows: <Window>[],
    );
  }

  @override
  List<Object> get props {
    return [
      loading,
      runningVersion,
      updateVersion,
      updateAvailable,
      currentDesktop,
      windows,
    ];
  }

  AppState copyWith({
    bool? loading,
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    int? currentDesktop,
    List<Window>? windows,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      currentDesktop: currentDesktop ?? this.currentDesktop,
      windows: windows ?? this.windows,
    );
  }
}
