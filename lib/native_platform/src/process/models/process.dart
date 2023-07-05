import 'package:freezed_annotation/freezed_annotation.dart';

part 'process.freezed.dart';

/// Current status of a process.
enum ProcessStatus {
  /// The process is running normally.
  // @JsonValue('normal')
  normal,

  /// The process is suspended.
  // @JsonValue('suspended')
  suspended,

  /// The process status is unknown.
  // @JsonValue('unknown')
  unknown,
}

/// Represents a running process on the host system.
@freezed
class Process with _$Process {
  const factory Process({
    /// Name of the executable, for example 'firefox' or 'firefox-bin'.
    required String executable,

    /// The Process ID (PID) of the given process.
    required int pid,

    /// Status will be one of [ProcessStatus.normal],
    /// [ProcessStatus.suspended] or [ProcessStatus.unknown].
    required ProcessStatus status,
  }) = _Process;
}
