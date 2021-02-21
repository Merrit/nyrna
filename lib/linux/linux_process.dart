import 'dart:io';

import 'package:nyrna/native_process.dart';

class LinuxProcess extends NativeProcess {
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
  Future<String> get status async {
    String _status;
    var result = await Process.run('ps', ['-o', 's=', '-p', '$pid']);
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
  Future<bool> toggle() async {
    var _status = await status;
    ProcessSignal signal =
        (_status == 'normal') ? ProcessSignal.sigstop : ProcessSignal.sigcont;
    bool successful = Process.killPid(pid, signal);
    return successful;
  }
}
