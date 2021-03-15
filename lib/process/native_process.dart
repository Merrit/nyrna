import 'package:nyrna/process/process_status.dart';

/// Abstract type bridges classes for specific operating systems.
/// Used by [LinuxProcess] and [WindowsProcess].
abstract class NativeProcess {
  /// Name of the executable, for example 'firefox' or 'firefox-bin'.
  Future<String> get executable;

  /// Status will be one of [ProcessStatus.normal],
  /// [ProcessStatus.suspended] or [ProcessStatus.unknown].
  Future<ProcessStatus> get status;

  /// Returns true for success or false for failure.
  Future<bool> toggle();
}
