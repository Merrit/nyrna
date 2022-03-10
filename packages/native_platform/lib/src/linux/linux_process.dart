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

  // Use built-in method  from dart:io to suspend & resume.
  @override
  Future<bool> toggle() async {
    await refreshStatus();
    final signal = (_status == ProcessStatus.normal)
        ? io.ProcessSignal.sigstop
        : io.ProcessSignal.sigcont;
    final successful = io.Process.killPid(pid, signal);
    return successful;
  }

  @override
  Future<bool> exists() async {
    final result = await io.Process.run(
      'ps',
      ['-q', '$pid', '-o', 'pid='],
    );
    final checkedPid = int.tryParse(result.stdout.toString().trim());
    return (checkedPid == pid) ? true : false;
  }

  @override
  Future<bool> resume() async {
    return io.Process.killPid(pid, io.ProcessSignal.sigcont);
  }

  @override
  Future<bool> suspend() async {
    return io.Process.killPid(pid, io.ProcessSignal.sigstop);
  }
}
