import 'dart:io' show ProcessResult, ProcessSignal;

import 'package:native_platform/src/process/models/process.dart';
import 'package:native_platform/src/typedefs.dart';

import '../process_repository.dart';

/// Provides interaction access with host system processes on Linux.
class LinuxProcessRepository extends ProcessRepository {
  final KillFunction _kill;
  final RunFunction _run;

  const LinuxProcessRepository(this._kill, this._run);

  @override
  Future<bool> exists(int pid) async {
    final result = await _run('ps', ['-q', '$pid', '-o', 'pid=']);
    final resultPid = int.tryParse(result.stdout.toString().trim());
    return (resultPid == pid) ? true : false;
  }

  @override
  Future<Process> getProcess(int pid) async {
    final executable = await _getExecutableName(pid);
    final status = await getProcessStatus(pid);
    final process = Process(executable: executable, pid: pid, status: status);
    return process;
  }

  Future<String> _getExecutableName(int pid) async {
    final ProcessResult result = await _run('readlink', ['/proc/$pid/exe']);
    if (result.exitCode == 1) return 'unknown';
    final executable = result.stdout.toString().split('/').last.trim();
    return executable;
  }

  @override
  Future<ProcessStatus> getProcessStatus(int pid) async {
    // For OSX you need to use `state=` in this command.
    // Just incase we ever add support for OSX.
    final ProcessResult result = await _run('ps', ['-o', 's=', '-p', '$pid']);
    if (result.exitCode == 1) return ProcessStatus.unknown;

    ProcessStatus status;

    switch (result.stdout.trim()) {
      case 'I':
        status = ProcessStatus.normal;
        break;
      case 'R':
        status = ProcessStatus.normal;
        break;
      case 'S':
        status = ProcessStatus.normal;
        break;
      case 'T':
        status = ProcessStatus.suspended;
        break;
      default:
        status = ProcessStatus.unknown;
    }

    return status;
  }

  @override
  Future<bool> resume(int pid) async {
    bool successful;
    successful = await _resumeChildren(pid);
    if (!successful) return false;

    successful = _resumePid(pid);
    if (!successful) return false;

    final status = await getProcessStatus(pid);

    return (status == ProcessStatus.normal) ? true : false;
  }

  /// Resume the provided [pid].
  bool _resumePid(int pid) {
    final bool successful = _kill(pid, ProcessSignal.sigcont);
    return successful;
  }

  /// Recursively resume child processes for [parentPid].
  Future<bool> _resumeChildren(int parentPid) async {
    final childPids = await _getChildPids(parentPid);
    if (childPids == null) return true;

    for (var childPid in childPids) {
      bool successful;
      // Resume further children recursively.
      successful = await _resumeChildren(childPid);
      if (!successful) return false;
      // Resume the original child.
      successful = _resumePid(childPid);
      if (!successful) return false;
    }

    return true;
  }

  @override
  Future<bool> suspend(int pid) async {
    bool successful;

    successful = await _suspendChildren(pid);
    if (!successful) {
      await _resumeChildren(pid);
      return false;
    }

    successful = _suspendPid(pid);
    if (!successful) {
      return false;
    }

    final status = await getProcessStatus(pid);

    if ((status == ProcessStatus.suspended)) {
      return true;
    } else {
      return false;
    }
  }

  /// Suspend the provided [pid].
  bool _suspendPid(int pid) {
    final bool successful = _kill(pid, ProcessSignal.sigstop);
    return successful;
  }

  /// Recursively suspend child processes for [parentPid].
  Future<bool> _suspendChildren(int parentPid) async {
    final childPids = await _getChildPids(parentPid);
    if (childPids == null) return true;

    for (var childPid in childPids) {
      bool successful;
      // Suspend further children recursively.
      successful = await _suspendChildren(childPid);
      if (!successful) return false;
      // Suspend the original child.
      successful = _suspendPid(childPid);
      if (!successful) return false;
    }

    return true;
  }

  /// Returns the pids for all processes that are children of [parentPid].
  Future<List<int>?> _getChildPids(int parentPid) async {
    final result = await _run('bash', ['-c', 'pgrep -P $parentPid']);
    if (result.stderr != '') {
      print('Unable to get child pids: ${result.stderr}');
      return null;
    }
    final childPids = result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((e) => e.trim() != '')
        .map((e) => int.parse(e))
        .toList();
    return childPids;
  }
}
