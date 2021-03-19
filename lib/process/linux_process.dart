import 'dart:io';

import 'package:nyrna/process/native_process.dart';
import 'package:nyrna/process/process_status.dart';

class LinuxProcess implements NativeProcess {
  LinuxProcess(this.pid);

  final int pid;

  String _executable;

  @override
  Future<String> get executable async {
    if (_executable != null) return _executable;
    var result = await Process.run('readlink', ['/proc/$pid/exe']);
    _executable = result.stdout.toString().split('/').last.trim();
    return _executable;
  }

  @override
  Future<ProcessStatus> get status async {
    ProcessStatus _status;
    var result = await Process.run('ps', ['-o', 's=', '-p', '$pid']);
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

  @override
  Future<bool> toggle() async {
    var _status = await status;
    final signal = (_status == ProcessStatus.normal)
        ? ProcessSignal.sigstop
        : ProcessSignal.sigcont;
    final successful = Process.killPid(pid, signal);
    return successful;
  }
}
