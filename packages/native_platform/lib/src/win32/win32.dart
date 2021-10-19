import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../active_window.dart';
import '../native_platform.dart';
import '../native_process.dart';
import '../process.dart';
import '../window.dart';
import 'win32_process.dart';

export 'win32_process.dart';

/// Interact with the native win32 operating system.
///
/// Requires many syscalls to the win32 API.
class Win32 implements NativePlatform {
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
    final win32Process = Win32Process(pid);
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

  @override
  Future<NativeProcess> windowProcess(int windowId) async {
    final pid = await windowPid(windowId);
    final process = Win32Process(pid);
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

  Future<List<Window>> buildWindows(List<Map<int, String>> windowMaps) async {
    final windows = <Window>[];
    await Future.forEach(
      windowMaps,
      (Map<int, String> window) async {
        final windowId = window.keys.first;
        final title = window.values.first;
        final win32Process = await windowProcess(windowId);
        final executable = await win32Process.executable;
        final pid = win32Process.pid;
        final process = Process(
          executable: executable,
          pid: pid,
          status: ProcessStatus.unknown,
        );
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
