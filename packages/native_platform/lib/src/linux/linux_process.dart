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
    final successful = io.Process.killPid(pid, io.ProcessSignal.sigstop);
    if (!successful) return false;

    await refreshStatus();

    return (status == ProcessStatus.suspended) ? true : false;
  }

  @override
  Future<bool> resume() async {
    final successful = io.Process.killPid(pid, io.ProcessSignal.sigcont);
    if (!successful) return false;

    await refreshStatus();

    return (status == ProcessStatus.normal) ? true : false;
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
}
