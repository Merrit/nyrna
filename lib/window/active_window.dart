import 'dart:io' as io;

import 'package:nyrna/platform/native_platform.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/process/process_status.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window/window_controls.dart';
import 'package:win32/win32.dart';

/// Represents the active, foreground window on the system.
///
/// initialize() must be called before anything else.
class ActiveWindow {
  ActiveWindow()
      : _nativePlatform = NativePlatform(),
        _windowControls = WindowControlsProvider.getNativeControls();

  NativePlatform _nativePlatform;

  WindowControls _windowControls;

  int nyrnaPid;

  int pid;

  int id;

  /// Hide the Nyrna window.
  ///
  /// Necessary when using the toggle active window feature,
  /// until Flutter has a way to run without GUI.
  Future<void> hideNyrna() async {
    switch (io.Platform.operatingSystem) {
      case 'linux':
        await _hideLinux();
        break;
      case 'windows':
        await _hideWindows();
        break;
      default:
        break;
    }
  }

  Future<void> _hideLinux() async {
    await io.Process.run(
      'xdotool',
      ['getactivewindow', 'windowunmap', '--sync'],
    );
  }

  Future<void> _hideWindows() async {
    var id = GetForegroundWindow();
    // We would prefer SW_HIDE, however that leaves Nyrna still
    // considered the foreground window. So, minimize instead.
    ShowWindow(id, SW_FORCEMINIMIZE);
  }

  Future<void> initialize() async {
    nyrnaPid = io.pid;
    pid = await _nativePlatform.activeWindowPid;
    _verifyPid();
    id = await _nativePlatform.activeWindowId;
  }

  // This _could_ happen because we have to hide Nyrna's window instead of
  // just not running the GUI for now. Sanity check here.
  void _verifyPid() {
    if (pid == nyrnaPid) {
      print("Active window PID was Nyrna's own, this shouldn't happen...");
      io.exit(1);
    }
  }

  /// Toggle the suspend / resume state of the given process.
  Future<void> toggle() async {
    if (settings.savedProcess != 0) {
      await _resume();
    } else {
      await _suspend();
    }
  }

  Future<void> _resume() async {
    pid = settings.savedProcess;
    id = settings.savedWindowId;
    var process = Process(pid);
    var _status = await process.status;
    if (_status == ProcessStatus.suspended) {
      await process.toggle();
      await settings.setSavedProcess(0);
      await settings.setSavedWindowId(0);
    }
    await _windowControls.restore(id);
  }

  Future<void> _suspend() async {
    var process = Process(pid);
    await _windowControls.minimize(id);
    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    var successful = await process.toggle();
    await settings.setSavedProcess(pid);
    await settings.setSavedWindowId(id);
    if (!successful) {
      // TODO: Notify user of failure.
    }
  }
}
