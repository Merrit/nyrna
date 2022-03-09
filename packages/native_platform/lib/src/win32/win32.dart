import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:logging/logging.dart';

import '../active_window.dart';
import '../native_platform.dart';
import '../process.dart';
import '../window.dart';
import 'win32_process.dart';

export 'win32_process.dart';

/// System-level or non-app executables. Nyrna shouldn't show these.
const List<String> _filteredWindows = [
  'nyrna.exe',
  'ApplicationFrameHost.exe', // Manages UWP (Universal Windows Platform) apps
  'dwm.exe', // Win32's compositing window manager
  'explorer.exe', // Windows File Explorer
  'googledrivesync.exe',
  'LogiOverlay.exe', // Logitech Options
  'PenTablet.exe', // XP-PEN driver
  'perfmon.exe', // Resource Monitor
  'Rainmeter.exe',
  'SystemSettings.exe', // Windows system settings
  'Taskmgr.exe', // Windows Task Manager
  'TextInputHost.exe', // Microsoft Text Input Application
  'WinStore.App.exe', // Windows Store
];

/// Interact with the native win32 operating system.
///
/// Requires many syscalls to the win32 API.
class Win32 implements NativePlatform {
  static final _log = Logger('Win32');

  // Not available on Windows, so just return 0 always.
  @override
  Future<int> currentDesktop() async => 0;

  @override
  Future<List<Window>> windows({required bool showHidden}) async {
    // Clear the map to ensure we are starting fresh each time.
    WindowBuilder.windows.clear();
    WindowBuilder.showHiddenWindows = showHidden;
    // Process open windows.
    /// [EnumWindows] returns 0 for failure.
    final result = EnumWindows(WindowBuilder.callback, 0);
    if (result == 0) {
      print('Error from EnumWindows getting open windows');
      return [];
    }
    final windowMap = WindowBuilder.windows;
    final windows = await buildWindows(windowMap);
    return windows;
  }

  late int _windowPid;

  /// Takes the window handle as an argument and returns the
  /// pid of the associated process.
  @override
  Future<int> windowPid(int windowId) async {
    // GetWindowThreadProcessId will assign the PID to this pointer.
    final _pid = calloc<Uint32>();
    // Populate the `_pid` pointer.
    GetWindowThreadProcessId(windowId, _pid);
    // Extract value from the pointer.
    _windowPid = _pid.value;
    // Free the pointer memory.
    calloc.free(_pid);
    return _windowPid;
  }

  @override
  Future<ActiveWindow> activeWindow() async {
    final windowId = await activeWindowId;
    final pid = await windowPid(windowId);
    final executable = await getExecutableName(pid);
    final win32Process = Win32Process(this, pid: pid, executable: executable);
    final activeWindow = ActiveWindow(
      NativePlatform(),
      win32Process,
      id: windowId,
      pid: pid,
    );
    return activeWindow;
  }

  Future<int> get activeWindowPid async {
    final windowId = await activeWindowId;
    return windowPid(windowId);
  }

  Future<int> get activeWindowId async => GetForegroundWindow();

  // No external dependencies for Win32, so always return true.
  @override
  Future<bool> checkDependencies() async => true;

  Future<Process> windowProcess(int windowId) async {
    final pid = await windowPid(windowId);
    final executable = await getExecutableName(pid);
    final process = Win32Process(this, pid: pid, executable: executable);
    return process;
  }

  @override
  Future<bool> minimizeWindow(int windowId) async {
    ShowWindow(windowId, SW_FORCEMINIMIZE);
    return true; // [ShowWindow] return value doesn't confirm success.
  }

  @override
  Future<bool> restoreWindow(int windowId) async {
    ShowWindow(windowId, SW_RESTORE);
    return true; // [ShowWindow] return value doesn't confirm success.
  }

  Future<String> getExecutableName(int pid) async {
    final processHandle =
        OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    // Pointer that will be populated with the full executable path.
    final path = calloc<Uint16>(MAX_PATH).cast<Utf16>();
    // If the GetModuleFileNameEx function succeeds, the return value specifies
    // the length of the string copied to the buffer.
    // If the function fails, the return value is zero.
    final result = GetModuleFileNameEx(processHandle, NULL, path, MAX_PATH);
    if (result == 0) {
      _log.warning('Error getting executable name: ${GetLastError()}');
      return '';
    }
    // Pull the value from the pointer.
    // Discard all of path except the executable name.
    final _executable = path.toDartString().split('\\').last;
    // Free the pointer's memory.
    calloc.free(path);
    final handleClosed = CloseHandle(processHandle);
    if (handleClosed == 0) {
      _log.severe('get executable failed to close the process handle.');
    }
    return _executable;
  }

  Future<List<Window>> buildWindows(List<Map<int, String>> windowMaps) async {
    final windows = <Window>[];
    await Future.forEach(
      windowMaps,
      (Map<int, String> window) async {
        final windowId = window.keys.first;
        final title = window.values.first;
        final win32Process = await windowProcess(windowId);
        final executable = win32Process.executable;
        if (_filteredWindows.contains(executable)) return;
        final pid = win32Process.pid;
        final process = Process(pid: pid, executable: executable);
        windows.add(
          Window(
            id: windowId,
            process: process,
            title: title,
          ),
        );
      },
    );
    return windows;
  }
}

// Static methods required because the win32 callback is required to be static.
//
/// Generates the list of visible windows on the user's desktop.
class WindowBuilder {
  static bool showHiddenWindows = false;

  /// Persistant callback because:
  /// "The pointer returned will remain alive for the
  /// duration of the current isolate's lifetime."
  /// https://api.flutter.dev/flutter/dart-ffi/Pointer/fromFunction.html
  static final callback = Pointer.fromFunction<EnumWindowsProc>(
      WindowBuilder.enumWindowsCallback, 0);

  /// Callback for each window found by EnumWindows().
  static int enumWindowsCallback(int hWnd, int lParam) {
    // Only enumerate windows that are marked WS_VISIBLE.
    if (IsWindowVisible(hWnd) == FALSE) return TRUE;
    if (!showHiddenWindows) {
      // Only enumerate windows that aren't `cloaked`.
      if (_isDwmCloaked(hWnd)) return TRUE;
    }
    final length = GetWindowTextLength(hWnd);
    // Only enumerate windows with title text.
    if (length == 0) return TRUE;
    // Initialize pointer for title text.
    final buffer = calloc<Uint16>(length + 1).cast<Utf16>();
    // Populate pointer.
    GetWindowText(hWnd, buffer, length + 1);
    // Callback to build Window object with pointer value.
    _buildWindowMap(hWnd, buffer.toDartString());
    // Free pointer memory.
    calloc.free(buffer);
    return TRUE;
  }

  /// Check if the window has the `DWMWA_CLOAKED` attribute.
  ///
  /// Returns `true` if cloaked, `false` if not.
  ///
  /// This attribute is set by the Desktop Window Manager (DWM),
  /// similar to yet seperate from `IsWindowVisible()`.
  ///
  /// This is applied to many basic Windows apps and most (all?)
  /// Universal Windows Platform (UWP) apps that idle in the background.
  ///
  /// A side benefit is if an application is on a different virtual desktop
  /// than the active one it will be considered 'cloaked'. Therefore this
  /// function will also filter to only list apps on the current desktop.
  static bool _isDwmCloaked(int hWnd) {
    // Initialize memory for the result pointer.
    final result = calloc<Uint32>();
    // Populate into the `result` pointer.
    const DWMWA_CLOAKED = 14;
    DwmGetWindowAttribute(hWnd, DWMWA_CLOAKED, result, sizeOf<Uint32>());
    // Pull the value from the pointer.
    var cloakedReason = result.value;
    // Free the memory now that we have the value.
    calloc.free(result);
    // If the value is 0, the window is not cloaked.
    // Values of 1, 2 or 4 indicate the reasons it _is_ cloaked.
    // Reference:
    // https://docs.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
    return (cloakedReason == 0) ? false : true;
  }

  static List<Map<int, String>> windows = [];

  /// Called during the callback for every window to map the data.
  static void _buildWindowMap(int windowId, String title) {
    windows.add({
      windowId: title,
    });
  }
}
