import 'dart:io' as io;

import 'linux/linux_process.dart';
import 'win32/win32.dart';

enum ProcessStatus {
  normal,
  suspended,
  unknown,
}

/// Represents a process including its metadata and controls.
///
/// Abstract class bridges types for specific operating systems.
/// Used by [LinuxProcess] and [Win32Process].
abstract class Process {
  // ignore: unused_element
  const Process._(this.executable, this.pid);

  // Return correct subtype depending on the current operating system.
  factory Process({required String executable, required int pid}) {
    if (io.Platform.isLinux) {
      return LinuxProcess(executable: executable, pid: pid);
    } else {
      return Win32Process(Win32(), executable: executable, pid: pid);
    }
  }

  /// The Process ID (PID) of the given process.
  final int pid;

  /// Name of the executable, for example 'firefox' or 'firefox-bin'.
  final String executable;

  /// Status will be one of [ProcessStatus.normal],
  /// [ProcessStatus.suspended] or [ProcessStatus.unknown].
  ProcessStatus get status;

  /// Re-checks the process and updates [status].
  Future<void> refreshStatus();

  /// Toggle the suspend / resume state of the given process.
  ///
  /// Returns true for success or false for failure.
  Future<bool> toggle();

  Future<bool> suspend();

  Future<bool> resume();

  /// Whether or not a process with the given pid currently exists.
  ///
  /// ActiveWindow uses this to check a saved pid is still around.
  Future<bool> exists();
}
