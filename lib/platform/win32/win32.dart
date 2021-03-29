import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:nyrna/platform/win32/dwmapi.dart';
import 'package:nyrna/process/win32_process.dart';
import 'package:nyrna/platform/win32/user32.dart';
import 'package:nyrna/platform/native_platform.dart';
import 'package:nyrna/window/window.dart';
import 'package:win32/win32.dart';

/// Interact with the native win32 operating system.
///
/// Requires many syscalls to the win32 API.
class Win32 implements NativePlatform {
  // Not available on Windows, so just return 0 always.
  @override
  Future<int> get currentDesktop async => 0;

  @override
  Future<Map<String, Window>> get windows async {
    // Clear the map to ensure we are starting fresh each time.
    WindowBuilder.windows.clear();
    // Process open windows.
    EnumWindows(WindowBuilder.callback, 0);
    return WindowBuilder.windows;
  }

  int _windowPid;

  /// Takes the window handle as an argument and returns the
  /// pid of the associated process.
  int getWindowPid(int windowId) {
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
  Future<int> get activeWindowPid async {
    final windowId = await activeWindowId;
    return getWindowPid(windowId);
  }

  @override
  Future<int> get activeWindowId async => GetForegroundWindow();

  // No external dependencies for Win32, so always return true.
  @override
  Future<bool> checkDependencies() async => true;
}

// Static methods required because the win32 callback is required to be static.
//
/// Generates the list of visible windows on the user's desktop.
class WindowBuilder {
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
    // Only enumerate windows that aren't `cloaked`.
    if (_isDwmCloaked(hWnd)) return TRUE;
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

  static Map<String, Window> windows = {};

  /// Called during the callback for every window to map the data.
  static Future<void> _buildWindowMap(int windowId, String title) async {
    final pid = Win32().getWindowPid(windowId);
    final process = Win32Process(pid);
    final executable = await process.executable;
    if (!_filterWindows.contains(executable)) {
      windows[pid.toString()] = Window(
        title: title,
        id: windowId,
        pid: pid,
      );
    }
  }
}

/// System-level executables. Nyrna shouldn't show these.
List<String> _filterWindows = [
  'ApplicationFrameHost.exe', // Manages UWP (Universal Windows Platform) apps
  'explorer.exe', // Windows File Explorer
  'perfmon.exe', // Resource Monitor
  'SystemSettings.exe', // Windows system settings
  'Taskmgr.exe', // Windows Task Manager
  'TextInputHost.exe', // Microsoft Text Input Application
  'WinStore.App.exe', // Windows Store
];
