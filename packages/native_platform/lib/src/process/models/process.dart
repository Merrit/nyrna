import 'package:equatable/equatable.dart';

/// Current status of a process.
enum ProcessStatus {
  normal,
  suspended,
  unknown,
}

/// Represents a running process on the host system.
class Process extends Equatable {
  /// Name of the executable, for example 'firefox' or 'firefox-bin'.
  final String executable;

  /// The Process ID (PID) of the given process.
  final int pid;

  /// Status will be one of [ProcessStatus.normal],
  /// [ProcessStatus.suspended] or [ProcessStatus.unknown].
  final ProcessStatus status;

  const Process({
    required this.executable,
    required this.pid,
    required this.status,
  });

  Process copyWith({
    String? executable,
    int? pid,
    ProcessStatus? status,
  }) {
    return Process(
      executable: executable ?? this.executable,
      pid: pid ?? this.pid,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'Process(executable: $executable, pid: $pid, status: $status)';

  @override
  List<Object> get props => [executable, pid, status];
}
