import 'dart:io' as io;

import '../process.dart';

class LinuxProcess implements Process {
  @override
  final String executable;

  @override
  final int pid;

  LinuxProcess({required this.executable, required this.pid});

  ProcessStatus _status = ProcessStatus.unknown;

  @override
  ProcessStatus get status => _status;

  @override
  Future<void> refreshStatus() async {
    final result = await io.Process.run('ps', ['-o', 's=', '-p', '$pid']);
    // For OSX you need to use `state=` in this command.
    // Just incase we ever add support for OSX.

    switch (result.stdout.trim()) {
      case 'I':
        _status = ProcessStatus.normal;
        break;
      case 'R':
        _status = ProcessStatus.normal;
        break;
      case 'S':
        _status = ProcessStatus.normal;
        break;
      case 'T':
        _status = ProcessStatus.suspended;
        break;
      default:
        _status = ProcessStatus.unknown;
    }
  }

  // Use built-in method from dart:io to suspend & resume.
  @override
  Future<bool> toggle() async {
    await refreshStatus();

    final successful = (_status == ProcessStatus.normal) //
        ? await suspend()
        : await resume();

    return successful;
  }

  @override
  Future<bool> suspend() async {
    print('Suspending $executable with pid $pid');
    final String errorMsg = 'Unable to suspend $executable with pid of $pid.';

    bool successful;
    successful = await _suspendChildren(pid);
    if (!successful) {
      print(errorMsg);
      await _resumeChildren(pid);
      return false;
    }

    successful = _suspendPid(pid);
    if (!successful) {
      print(errorMsg);
      return false;
    }

    await refreshStatus();

    if ((status == ProcessStatus.suspended)) {
      print('Suspended $executable.');
      return true;
    } else {
      print('Failed to suspend $executable!');
      return false;
    }
  }

  /// Suspend the provided [pid].
  bool _suspendPid(int pid) {
    final bool successful = io.Process.killPid(pid, io.ProcessSignal.sigstop);
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

  @override
  Future<bool> resume() async {
    bool successful;
    successful = await _resumeChildren(pid);
    if (!successful) return false;

    successful = _resumePid(pid);
    if (!successful) return false;

    await refreshStatus();

    return (status == ProcessStatus.normal) ? true : false;
  }

  /// Resume the provided [pid].
  bool _resumePid(int pid) {
    final bool successful = io.Process.killPid(pid, io.ProcessSignal.sigcont);
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
  Future<bool> exists() async {
    final result = await io.Process.run(
      'ps',
      ['-q', '$pid', '-o', 'pid='],
    );

    final resultPid = int.tryParse(result.stdout.toString().trim());

    return (resultPid == pid) ? true : false;
  }

  /// Returns the pids for all processes that are children of [parentPid].
  static Future<List<int>?> _getChildPids(int parentPid) async {
    final result = await io.Process.run('bash', ['-c', 'pgrep -P $parentPid']);
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
