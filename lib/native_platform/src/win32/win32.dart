// ignore_for_file: constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../../../logs/logs.dart';
import '../native_platform.dart';
import '../process/models/process.dart';
import '../window.dart';

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
  // Not available on Windows, so just return 0 always.
  @override
  Future<int> currentDesktop() async => 0;

  @override
  Future<List<Window>> windows({bool showHidden = false}) async {
    WindowBuilder.showHiddenWindows = showHidden;
    final windows = await WindowBuilder.buildWindows();
    return windows;
  }

  @override
  Future<Window> activeWindow() async {
    final windowId = await _activeWindowId();
    final pid = await _pidFromWindowId(windowId);
    final executable = await getExecutableName(pid);
    final process = Process(
      pid: pid,
      executable: executable,
      status: ProcessStatus.unknown,
    );
    final title = getWindowTitle(windowId);

    return Window(id: windowId, process: process, title: title);
  }

  Future<int> _activeWindowId() async => GetForegroundWindow();

  Future<int> _pidFromWindowId(int windowId) async {
    final buffer = calloc<Uint32>();
    GetWindowThreadProcessId(windowId, buffer);

    // Extract value from the pointer.
    final pid = buffer.value;

    // Free the pointer memory.
    calloc.free(buffer);

    return pid;
  }

  String getWindowTitle(int windowId) {
    final length = GetWindowTextLength(windowId);
    if (length == 0) return '';

    final buffer = wsalloc(length + 1);
    GetWindowText(windowId, buffer, length + 1);
    final title = buffer.toDartString();
    free(buffer);

    return title;
  }

  // No external dependencies for Win32, so always return true.
  @override
  Future<bool> checkDependencies() async => true;

  Future<Process> processFromWindowId(int windowId) async {
    final pid = await _pidFromWindowId(windowId);
    final executable = await getExecutableName(pid);
    final process = Process(
      pid: pid,
      executable: executable,
      status: ProcessStatus.unknown,
    );
    return process;
  }

  @override
  Future<bool> minimizeWindow(int windowId) async {
    log.i('Minimizing window with id $windowId');
    ShowWindow(windowId, SHOW_WINDOW_CMD.SW_FORCEMINIMIZE);
    return true; // [ShowWindow] return value doesn't confirm success.
  }

  @override
  Future<bool> restoreWindow(int windowId) async {
    log.i('Restoring window with id $windowId');
    ShowWindow(windowId, SHOW_WINDOW_CMD.SW_RESTORE);
    return true; // [ShowWindow] return value doesn't confirm success.
  }

  Future<String> getExecutableName(int pid) async {
    final processHandle = OpenProcess(
      PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_LIMITED_INFORMATION,
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
      log.e('Failed to close the process handle.');
    }

    return executable;
  }
}

// Static methods required because the win32 callback is required to be static.
//
/// Generates the list of visible windows on the user's desktop.
class WindowBuilder {
  static bool showHiddenWindows = false;
  static final List<Window> _windows = [];

  static Future<List<Window>> buildWindows() async {
    /// [EnumWindows] calls [enumWindowsCallback] for every window.
    ///
    /// [EnumWindows] returns 0 for failure.
    final result = EnumWindows(_callback, 0);

    if (result == 0) {
      log.e('Error from EnumWindows getting open windows');
      return const [];
    }

    /// At this point [enumWindowsCallback] has finished & populated [_windows].
    final correctedWindows = <Window>[];

    for (var window in _windows) {
      final process = await Win32().processFromWindowId(window.id);

      if (_filteredWindows.contains(process.executable)) continue;

      correctedWindows.add(window.copyWith(process: process));
    }

    _windows.clear();

    return correctedWindows;
  }

  /// Persistant callback because:
  /// "The pointer returned will remain alive for the
  /// duration of the current isolate's lifetime."
  /// https://api.flutter.dev/flutter/dart-ffi/Pointer/fromFunction.html
  static final _callback = Pointer.fromFunction<WNDENUMPROC>(
    WindowBuilder.enumWindowsCallback,
    0,
  );

  /// Callback for each window found by `EnumWindows()`.
  ///
  /// The type signature must match what `EnumWindows()` requires,
  /// so this can't be async or anything.
  static int enumWindowsCallback(int hWnd, int lParam) {
    // Only enumerate windows that are marked WS_VISIBLE.
    if (IsWindowVisible(hWnd) == FALSE) return TRUE;

    if (!showHiddenWindows) {
      // Only enumerate windows that aren't `cloaked`.
      if (_isDwmCloaked(hWnd)) return TRUE;
    }

    final title = Win32().getWindowTitle(hWnd);
    // Ignore windows without title text, they are not likely to be
    // actual user windows that we care about.
    if (title == '') return TRUE;

    _windows.add(
      Window(
        id: hWnd,
        process: const Process(
          executable: '',
          pid: 0,
          status: ProcessStatus.unknown,
        ),
        title: title,
      ),
    );

    return TRUE;
  }

  static const DWMWA_CLOAKED = 14;

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
    final cloakedReason = result.value;

    // Free the memory now that we have the value.
    calloc.free(result);

    // If the value is 0, the window is not cloaked.
    // Values of 1, 2 or 4 indicate the reasons it _is_ cloaked.
    // Reference:
    // https://docs.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
    return (cloakedReason == 0) ? false : true;
  }
}
