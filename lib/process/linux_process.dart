import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:nyrna/process/process.dart';

class LinuxProcess with ChangeNotifier implements Process {
  LinuxProcess(this.pid);

  @override
  final int pid;

  String _executable;

  @override
  Future<String> get executable async {
    if (_executable != null) return _executable;
    final result = await io.Process.run('readlink', ['/proc/$pid/exe']);
    _executable = result.stdout.toString().split('/').last.trim();
    return _executable;
  }

  @override
  Future<ProcessStatus> get status async {
    ProcessStatus _status;
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
    return _status;
  }

  // Use built-in method  from dart:io to suspend & resume.
  @override
  Future<bool> toggle() async {
    var _status = await status;
    final signal = (_status == ProcessStatus.normal)
        ? io.ProcessSignal.sigstop
        : io.ProcessSignal.sigcont;
    final successful = io.Process.killPid(pid, signal);
    notifyListeners();
    return successful;
  }
}
