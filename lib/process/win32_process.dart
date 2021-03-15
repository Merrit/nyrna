import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:win32_suspend_process/win32_suspend_process.dart' as w32proc;

import 'package:nyrna/process/native_process.dart';
import 'package:nyrna/process/process_status.dart';

class Win32Process implements NativeProcess {
  Win32Process(this.pid);

  final int pid;

  String _executable;

  Future<String> get executable async {
    if (_executable != null) return _executable;
    final processHandle =
        OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    // Pointer that will be populated with the full executable path.
    var path = calloc<Uint16>(MAX_PATH).cast<Utf16>();
    // If the function succeeds, the return value specifies
    // the length of the string copied to the buffer.
    // If the function fails, the return value is zero.
    var result = GetModuleFileNameEx(processHandle, NULL, path, MAX_PATH);
    if (result == 0) {
      print('Error getting executable name: ${GetLastError()}');
      return '';
    }
    // Discard all of path except the executable name.
    _executable = path.toDartString().split('\\').last;
    // Clean up memory.
    calloc.free(path);
    CloseHandle(processHandle);
    return _executable;
  }

  // Get process suspended status from .NET calls through Powershell.
  //
  // This feels hacky and slow, but win32 doesn't really provide a better
  // method for doing this. There is discussion on GitHub about adding
  // support for C# to dart:ffi, if that comes to fruition
  // this can all be done through native calls to .NET instead.
  //
  // NtQuerySystemInformation() was a consideration, however it is
  // complicated, at threat of being depreciated, and since it has to
  // enumerate every process likely not much better performance-wise anyway.
  Future<ProcessStatus> get status async {
    final result = await Process.run(
      'powershell',
      [
        '\$process=[System.Diagnostics.Process]::GetProcessById($pid)',
        ';',
        '\$threads=\$process.Threads',
        ';',
        '\$threads | select Id,ThreadState,WaitReason',
      ],
    );
    if (result.stderr != "") return ProcessStatus.unknown;
    var threads = result.stdout.toString().trim().split('\n');
    // Strip out the column headers
    threads = threads.sublist(2);
    List<bool> suspended = [];
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
}
