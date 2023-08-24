import 'dart:io' as io;

import '../../linux/flatpak.dart';
import '../models/process.dart';
import 'src/linux_process_repository.dart';
import 'src/win32_process_repository.dart';

/// Provides interaction access with host system processes.
///
/// This abstract class will provide the correct implementation for the host
/// operating system when called with [ProcessRepository.init()].
abstract class ProcessRepository {
  const ProcessRepository();

  static ProcessRepository init() {
    if (io.Platform.isLinux) {
      final runFunction = (runningInFlatpak) ? flatpakRun : io.Process.run;
      final killFunction = (runningInFlatpak) //
          ? flatpakKill
          : io.Process.killPid;
      return LinuxProcessRepository(killFunction, runFunction);
    } else {
      return Win32ProcessRepository();
    }
  }

  /// Whether or not a process with the given pid currently exists.
  ///
  /// ActiveWindow uses this to check a saved pid is still around.
  Future<bool> exists(int pid);

  /// Returns a [Process] for the given [pid] if it exists, otherwise it returns
  /// a generic [Process] with a status of "unknown".
  Future<Process> getProcess(int pid);

  /// Returns the status of the process associated with [pid].
  ///
  /// If the process is not found or there is an error the status will be
  /// [ProcessStatus.unknown].
  Future<ProcessStatus> getProcessStatus(int pid);

  /// Attempts to resume a process associated with [pid].
  ///
  /// Return value is `true` if successful.
  Future<bool> resume(int pid);

  /// Attempts to suspend a process associated with [pid].
  ///
  /// Return value is `true` if successful.
  Future<bool> suspend(int pid);
}
