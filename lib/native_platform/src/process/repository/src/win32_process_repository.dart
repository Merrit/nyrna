import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';
import 'package:win32_suspend_process/win32_suspend_process.dart';

import '../../../../../logs/logs.dart';
import '../../process.dart';

/// Provides interaction access with host system processes on Windows.
class Win32ProcessRepository extends ProcessRepository {
  /// Native function that returns 1 if the process is suspended, 0 otherwise.
  final int Function(int pid) _isProcessSuspendedNative;

  Win32ProcessRepository._(this._isProcessSuspendedNative);

  factory Win32ProcessRepository() {
    /// Load the native library.
    final String nativeLibraryPath;
    if (kReleaseMode) {
      nativeLibraryPath =
          r'data\flutter_assets\assets\lib\windows\NativeLibrary.dll';
    } else {
      nativeLibraryPath = r'assets\lib\windows\NativeLibrary.dll';
    }

    final nativeLibrary = DynamicLibrary.open(nativeLibraryPath);

    final isProcessSuspendedNative =
        nativeLibrary.lookupFunction<Int32 Function(Int32), int Function(int)>(
      'IsProcessSuspended',
    );

    return Win32ProcessRepository._(isProcessSuspendedNative);
  }

  @override
  Future<bool> exists(int pid) async {
    final name = await _getExecutableName(pid);
    return (name == '') ? false : true;
  }

  @override
  Future<Process> getProcess(int pid) async {
    final executable = await _getExecutableName(pid);
    final status = await getProcessStatus(pid);
    final process = Process(executable: executable, pid: pid, status: status);
    return process;
  }

  Future<String> _getExecutableName(int pid) async {
    final processHandle = OpenProcess(
      PROCESS_QUERY_LIMITED_INFORMATION,
      FALSE,
      pid,
    );

    // Pointer that will be populated with the full executable path.
    final path = calloc<Uint16>(MAX_PATH).cast<Utf16>();

    // If the GetModuleFileNameEx function succeeds, the return value specifies
    // the length of the string copied to the buffer.
    // If the function fails, the return value is zero.
    final result = GetModuleFileNameEx(processHandle, NULL, path, MAX_PATH);

    if (result == 0) {
      log.w('Error getting executable name: ${GetLastError()}');
      return '';
    }

    // Pull the value from the pointer.
    // Discard all of path except the executable name.
    final executable = path.toDartString().split('\\').last;

    // Free the pointer's memory.
    calloc.free(path);

    final handleClosed = CloseHandle(processHandle);
    if (handleClosed == 0) {
      log.e('get executable failed to close the process handle.');
    }

    return executable;
  }

  @override
  Future<ProcessStatus> getProcessStatus(int pid) async {
    final isSuspended = _isProcessSuspended(pid);
    return isSuspended ? ProcessStatus.suspended : ProcessStatus.normal;
  }

  @override
  Future<bool> resume(int pid) async {
    final processHandle = OpenProcess(PROCESS_SUSPEND_RESUME, FALSE, pid);
    final result = NtResumeProcess(processHandle);
    final successful = (result == 0);
    log.i('Resuming $pid was successful: $successful');
    CloseHandle(processHandle);
    return successful;
  }

  @override
  Future<bool> suspend(int pid) async {
    final processHandle = OpenProcess(PROCESS_SUSPEND_RESUME, FALSE, pid);
    final result = NtSuspendProcess(processHandle);
    final successful = (result == 0);
    log.i('Suspending $pid was successful: $successful');
    CloseHandle(processHandle);
    return successful;
  }

  /// Returns true if the process is suspended, false otherwise.
  bool _isProcessSuspended(int pid) {
    return _isProcessSuspendedNative(pid) == 1;
  }
}
