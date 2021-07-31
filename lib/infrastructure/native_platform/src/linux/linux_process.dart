import 'dart:io' as io;

import 'package:nyrna/domain/native_platform/native_platform.dart';

import '../native_process.dart';

class LinuxProcess implements NativeProcess {
  LinuxProcess(this.pid);

  @override
  final int pid;

  String? _executable;

  @override
  Future<String> get executable async {
    if (_executable != null) return _executable!;
    final result = await io.Process.run('readlink', ['/proc/$pid/exe']);
    _executable = result.stdout.toString().split('/').last.trim();
    return _executable!;
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
