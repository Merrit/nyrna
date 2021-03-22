import 'dart:io' as io;

import 'package:nyrna/logger/logger.dart';
import 'package:nyrna/platform/native_platform.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window/window_controls.dart';
import 'package:win32/win32.dart';

/// Represents the active, foreground window on the system.
///
/// Initialize() must be called before anything else.
class ActiveWindow {
  final _nativePlatform = NativePlatform();

  final _windowControls = WindowControls();

  final _settings = Settings.instance;

  /// Nyrna's own PID.
  final int nyrnaPid = io.pid;

  int id;

  int pid;

  Future<void> initialize() async {
    pid = await _nativePlatform.activeWindowPid;
    _verifyPid();
    id = await _nativePlatform.activeWindowId;
  }

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

  /// Hide own window using `xdotool`.
  Future<void> _hideLinux() async {
    await io.Process.run(
      'xdotool',
      ['getactivewindow', 'windowunmap', '--sync'],
    );
  }

  /// Hide own window using the win32 API.
  Future<void> _hideWindows() async {
    var id = GetForegroundWindow();
    // We would prefer SW_HIDE, however that leaves Nyrna still
    // considered the foreground window. So, minimize instead.
    ShowWindow(id, SW_FORCEMINIMIZE);
  }

  // This _could_ happen because we have to hide Nyrna's window instead of
  // just not running the GUI for now. Sanity check: don't suspend self.
  void _verifyPid() {
    if (pid == nyrnaPid) {
      print("Active window PID was Nyrna's own, this shouldn't happen...");
      final logger = Logger.instance;
      logger.flush('Active window was Nyrna');
      io.exit(1);
    }
  }

  /// Toggle the suspend / resume state of the given process.
  Future<void> toggle() async {
    if (_settings.savedProcess != 0) {
      await _resume();
    } else {
      await _suspend();
    }
  }

  Future<void> _resume() async {
    pid = _settings.savedProcess;
    id = _settings.savedWindowId;
    final process = Process(pid);
    final _status = await process.status;
    if (_status == ProcessStatus.suspended) {
      await process.toggle();
      await _settings.setSavedProcess(0);
      await _settings.setSavedWindowId(0);
    }
    await _windowControls.restore(id);
  }

  Future<void> _suspend() async {
    final process = Process(pid);
    await _windowControls.minimize(id);
    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    final successful = await process.toggle();
    await _settings.setSavedProcess(pid);
    await _settings.setSavedWindowId(id);
    if (!successful) {
      // TODO: Notify user of failure.
    }
  }
}
