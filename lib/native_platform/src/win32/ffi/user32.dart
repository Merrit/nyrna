/// Win32 wrapper for user32.dll API syscalls.
///
/// https://docs.microsoft.com/en-us/windows/win32/api/winuser/

import 'dart:ffi';

final _user32 = DynamicLibrary.open('user32.dll');

/// Retrieves the identifier of the thread that created the specified window
/// and, optionally, the identifier of the process that created the window.
///
/// ```cpp
/// DWORD GetWindowThreadProcessId(
///   HWND    hWnd,
///   LPDWORD lpdwProcessId
/// );
/// ```
int GetWindowThreadProcessId(int hWnd, Pointer<Uint32> lpdwProcessId) {
  final _GetWindowThreadProcessId = _user32.lookupFunction<
      Uint32 Function(Int32 hWnd, Pointer<Uint32> lpdwProcessId),
      int Function(
          int hWnd, Pointer<Uint32> lwpdProcessId)>('GetWindowThreadProcessId');
  return _GetWindowThreadProcessId(hWnd, lpdwProcessId);
}
