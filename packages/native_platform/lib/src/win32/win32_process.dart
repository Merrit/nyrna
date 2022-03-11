import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:native_platform/src/win32/win32.dart';
import 'package:win32_suspend_process/win32_suspend_process.dart' as w32proc;

import '../process.dart';

class Win32Process implements Process {
  @override
  final String executable;

  @override
  final int pid;

  final Win32 _win32;

  Win32Process(this._win32, {required this.executable, required this.pid});

  static final _log = Logger('Win32Process');

  ProcessStatus _status = ProcessStatus.unknown;

  @override
  ProcessStatus get status => _status;

  // Get process suspended status from .NET calls through Powershell.
  //
  // This feels hacky and slow, but the win32 API doesn't really provide a
  // better method for doing this. There is discussion on GitHub about adding
  // support for C# to dart:ffi, if that comes to fruition
  // this can all be done through native calls to .NET instead.
  // Reference:
  // https://github.com/flutter/flutter/issues/74720
  // https://github.com/flutter/flutter/issues/64958
  //
  // NtQuerySystemInformation() was a consideration, however it is
  // complicated, at threat of being depreciated, and since it has to
  // enumerate every process likely not much better performance-wise anyway.
  @override
  Future<void> refreshStatus() async {
    final result = await io.Process.run(
      'powershell',
      [
        '-NoProfile',
        '\$process=[System.Diagnostics.Process]::GetProcessById($pid)',
        ';',
        '\$threads=\$process.Threads',
        ';',
        '\$threads | select Id,ThreadState,WaitReason',
      ],
    );

    if (result.stderr != '') {
      _log.warning('Unable to get process status', result.stderr);
      _status = ProcessStatus.unknown;
      return;
    }

    var threads = result.stdout.toString().trim().split('\n');
    // Strip out the column headers
    threads = threads.sublist(2);

    final suspended = <bool>[];
    // Check each thread's status, track in [suspended] variable.
    threads.forEach((thread) {
      final threadWaitReason = thread.split(' ').last.trim();
      if (threadWaitReason == 'Suspended') {
        suspended.add(true);
      } else {
        suspended.add(false);
      }
    });

    // If every thread has the `Suspended` status, process is suspended.
    _status = suspended.contains(false)
        ? ProcessStatus.normal
        : ProcessStatus.suspended;
  }

  // Use the w32_suspend_process library to suspend & resume.
  @override
  Future<bool> toggle() async {
    await refreshStatus();

    if (_status == ProcessStatus.unknown) return false;

    final successful = (_status == ProcessStatus.normal) //
        ? await suspend()
        : await resume();

    return successful;
  }

  @override
  Future<bool> suspend() async {
    final successful = w32proc.Win32Process(pid).suspend();
    if (!successful) return false;

    await refreshStatus();

    return (status == ProcessStatus.suspended) ? true : false;
  }

  @override
  Future<bool> resume() async {
    final successful = w32proc.Win32Process(pid).resume();
    if (!successful) return false;

    await refreshStatus();

    return (status == ProcessStatus.normal) ? true : false;
  }

  // If the pid doesn't exist this won't be able to return the exe name.
  @override
  Future<bool> exists() async {
    final name = await _win32.getExecutableName(pid);
    return (name == '') ? false : true;
  }
}
