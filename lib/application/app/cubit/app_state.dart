part of 'app_cubit.dart';

class AppState extends Equatable {
  final bool loading;

  final String runningVersion;
  final String updateVersion;
  final bool updateAvailable;

  final List<Window> windows;

  const AppState({
    required this.loading,
    required this.runningVersion,
    required this.updateVersion,
    required this.updateAvailable,
    required this.windows,
  });

  factory AppState.initial() {
    return AppState(
      loading: true,
      runningVersion: '',
      updateVersion: '',
      updateAvailable: false,
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
      windows,
    ];
  }

  AppState copyWith({
    bool? loading,
    String? runningVersion,
    String? updateVersion,
    bool? updateAvailable,
    List<Window>? windows,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      runningVersion: runningVersion ?? this.runningVersion,
      updateVersion: updateVersion ?? this.updateVersion,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      windows: windows ?? this.windows,
    );
  }
}
