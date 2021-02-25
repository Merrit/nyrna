import 'dart:io' as io show pid, exit;

import 'package:nyrna/platform/native_platform.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window/window_controls.dart';

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

  Future<void> toggle() async {
    if (settings.savedProcess != null) {
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
    if (_status == 'suspended') {
      await process.toggle();
      await settings.setSavedProcess(null);
      await settings.setSavedWindowId(null);
    }
    await _windowControls.restore(id);
  }

  Future<void> _suspend() async {
    var process = Process(pid);
    await _windowControls.minimize(id);
    var successful = await process.toggle();
    await settings.setSavedProcess(pid);
    await settings.setSavedWindowId(id);
    if (!successful) {
      // TODO: Notify user of failure.
    }
  }
}
