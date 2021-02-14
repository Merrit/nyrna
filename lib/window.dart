import 'dart:io' as DartIO;

import 'package:nyrna/linux/linux.dart';
import 'package:nyrna/process.dart' as NyrnaProcess;
import 'package:nyrna/settings/settings.dart';

class Window {
  Window({this.title, this.pid, this.id});

  String title;
  int pid;

  /// Unique window id from the hexadecimal integer.
  int id;

  void minimize() {
    if (DartIO.Platform.isLinux) {
      DartIO.Process.runSync(
        'xdotool',
        ['windowminimize', '$id', '--sync'],
      );
    }
  }

  void restore() {
    if (DartIO.Platform.isLinux) {
      DartIO.Process.runSync(
        'xdotool',
        ['windowactivate', '$id', '--sync'],
      );
    }
  }
}

class ActiveWindow extends Window {
  ActiveWindow()
      : nyrnaPid = DartIO.pid,
        _pid = _activeWindowPid(),
        _id = _activeWindowId() {
    if (_pid == nyrnaPid) {
      print("Active window PID was Nyrna's own, this shouldn't happen...");
      DartIO.exit(1);
    }
  }

  final int nyrnaPid;

  int _pid;

  int get pid => _pid;

  int _id;

  int get id => _id;

  static int _activeWindowPid() {
    int _activePid;
    switch (DartIO.Platform.operatingSystem) {
      case 'linux':
        _activePid = Linux.activeWindowPid;
        break;
      default:
    }
    return _activePid;
  }

  static int _activeWindowId() {
    int _activeId;
    switch (DartIO.Platform.operatingSystem) {
      case 'linux':
        _activeId = Linux.activeWindowId;
        break;
      default:
    }
    return _activeId;
  }

  Future<void> toggle() async {
    if (settings.savedProcess != null) {
      await _resume();
    } else {
      var process = NyrnaProcess.Process(pid);
      await _suspend(process);
    }
    return null;
  }

  Future<void> _resume() async {
    _pid = settings.savedProcess;
    _id = settings.savedWindowId;
    var process = NyrnaProcess.Process(_pid);
    if (process.status == 'suspended') {
      process.toggle();
      await settings.setSavedProcess(null);
      await settings.setSavedWindowId(null);
    }
    restore();
    return null;
  }

  Future<void> _suspend(NyrnaProcess.Process process) async {
    minimize();
    var successful = process.toggle();
    await settings.setSavedProcess(pid);
    await settings.setSavedWindowId(id);
    if (!successful) {
      // Notify user of failure.
    }
    return null;
  }
}
