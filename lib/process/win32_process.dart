import 'dart:ffi';
import 'dart:io' as io;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/process/process.dart';
import 'package:win32/win32.dart';
import 'package:win32_suspend_process/win32_suspend_process.dart' as w32proc;

class Win32Process with ChangeNotifier implements Process {
  Win32Process(this.pid);

  @override
  final int pid;

  static final _log = Logger('Win32Process');

  String _executable;

  @override
  Future<String> get executable async {
    if (_executable != null) return _executable;
    final processHandle =
        OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    // Pointer that will be populated with the full executable path.
    final path = calloc<Uint16>(MAX_PATH).cast<Utf16>();
    // If the GetModuleFileNameEx function succeeds, the return value specifies
    // the length of the string copied to the buffer.
    // If the function fails, the return value is zero.
    final result = GetModuleFileNameEx(processHandle, NULL, path, MAX_PATH);
    if (result == 0) {
      print('Error getting executable name: ${GetLastError()}');
      return '';
    }
    // Pull the value from the pointer.
    // Discard all of path except the executable name.
    _executable = path.toDartString().split('\\').last;
    // Free the pointer's memory.
    calloc.free(path);
    final handleClosed = CloseHandle(processHandle);
    if (handleClosed == 0) {
      _log.severe('get executable failed to close the process handle.');
    }
    return _executable;
  }

  // Get process suspended status from .NET calls through Powershell.
  //
  // This feels hacky and slow, but the win32 API doesn't really provide a
  // better method for doing this. There is discussion on GitHub about adding
  // support for C# to dart:ffi, if that comes to fruition
  // this can all be done through native calls to .NET instead.
  //
  // NtQuerySystemInformation() was a consideration, however it is
  // complicated, at threat of being depreciated, and since it has to
  // enumerate every process likely not much better performance-wise anyway.
  @override
  Future<ProcessStatus> get status async {
    final result = await io.Process.run(
      'powershell',
      [
        '\$process=[System.Diagnostics.Process]::GetProcessById($pid)',
        ';',
        '\$threads=\$process.Threads',
        ';',
        '\$threads | select Id,ThreadState,WaitReason',
      ],
    );
    if (result.stderr != '') return ProcessStatus.unknown;
    var threads = result.stdout.toString().trim().split('\n');
    // Strip out the column headers
    threads = threads.sublist(2);
    final suspended = <bool>[];
    // Check each thread's status, track in [suspended] variable.
    threads.forEach((thread) {
      final threadWaitReason = thread.split(' ').last.trim();
      (threadWaitReason == 'Suspended')
          ? suspended.add(true)
          : suspended.add(false);
    });
    // If every thread has the `Suspended` status, process is suspended.
    return suspended.contains(false)
        ? ProcessStatus.normal
        : ProcessStatus.suspended;
  }

  // Use the w32_suspend_process library to suspend & resume.
  @override
  Future<bool> toggle() async {
    final _status = await status;
    if (_status == ProcessStatus.unknown) return false;
    final _process = w32proc.Win32Process(pid);
    bool _success;
    if (_status == ProcessStatus.suspended) {
      _success = _process.resume();
    } else {
      _success = _process.suspend();
    }
    return _success;
  }

  // If the pid doesn't exist this won't be able to return the exe name.
  @override
  Future<bool> exists() async {
    final name = await executable;
    return (name == '') ? false : true;
  }
}
