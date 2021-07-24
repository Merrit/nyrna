part of 'app_cubit.dart';

class AppState extends Equatable {
  /// The index of the currently active virtual desktop.
  final int currentDesktop;

  final Map<String, Window> windows;

  const AppState._internal({
    required this.currentDesktop,
    required this.windows,
  });

  factory AppState.initial() {
    return AppState._internal(
      currentDesktop: 0,
      windows: <String, Window>{},
    );
  }

  @override
  List<Object> get props => [
        currentDesktop,
        windows,
      ];

  AppState copyWith({
    int? currentDesktop,
    Map<String, Window>? windows,
  }) {
    return AppState._internal(
      currentDesktop: currentDesktop ?? this.currentDesktop,
      windows: windows ?? this.windows,
    );
  }
}
