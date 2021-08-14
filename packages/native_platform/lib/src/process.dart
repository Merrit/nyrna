import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum ProcessStatus {
  normal,
  suspended,
  unknown,
}

/// Friendly representation of a running process.
@immutable
class Process extends Equatable {
  final String executable;
  final int pid;
  final ProcessStatus status;

  Process({
    required this.executable,
    required this.pid,
    required this.status,
  });

  @override
  List<Object> get props => [executable, pid, status];

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
}
