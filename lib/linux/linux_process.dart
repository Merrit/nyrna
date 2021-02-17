import 'dart:io';

import 'package:nyrna/native_process.dart';

class LinuxProcess extends NativeProcess {
  LinuxProcess(this.pid) {
    executable = _checkExecutable();
  }

  final int pid;

  String executable;

  String _checkExecutable() {
    var result = Process.runSync('readlink', ['/proc/$pid/exe']);
    var _exec = result.stdout.toString().split('/').last.trim();
    return _exec;
  }

  @override
  String get status {
    String _status;
    var result = Process.runSync('ps', ['-o', 's=', '-p', '$pid']);
    // For OSX you need to use `state=` in this command.
    switch (result.stdout.trim()) {
      case 'I':
        _status = 'normal';
        break;
      case 'R':
        _status = 'normal';
        break;
      case 'S':
        _status = 'normal';
        break;
      case 'T':
        _status = 'suspended';
        break;
      default:
        _status = 'unknown';
    }
    return _status;
  }

  @override
  bool toggle() {
    ProcessSignal signal =
        (status == 'normal') ? ProcessSignal.sigstop : ProcessSignal.sigcont;
    bool successful = Process.killPid(pid, signal);
    return successful;
  }
}
