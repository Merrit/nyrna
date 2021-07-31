part of 'window_cubit.dart';

@immutable
class WindowState extends Equatable {
  final String executable;
  final int pid;
  final ProcessStatus processStatus;
  final String title;
  final ToggleError toggleError;

  const WindowState({
    required this.executable,
    required this.pid,
    required this.processStatus,
    required this.title,
    required this.toggleError,
  });

  @override
  List<Object> get props {
    return [
      executable,
      pid,
      processStatus,
      title,
      toggleError,
    ];
  }

  WindowState copyWith({
    String? executable,
    int? pid,
    ProcessStatus? processStatus,
    String? title,
    ToggleError? toggleError,
  }) {
    return WindowState(
      executable: executable ?? this.executable,
      pid: pid ?? this.pid,
      processStatus: processStatus ?? this.processStatus,
      title: title ?? this.title,
      toggleError: toggleError ?? this.toggleError,
    );
  }
}
