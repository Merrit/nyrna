import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/domain/arguments/argument_parser.dart';
import 'package:nyrna/infrastructure/logger/log_file.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/infrastructure/native_platform/src/process.dart';
import 'package:win32/win32.dart';

/// Represents the active, foreground window on the system.
///
/// Initialize() must be called before anything else.
class ActiveWindow {
  final _nativePlatform = NativePlatform();

  final _windowControls = WindowControls();

  static final _log = Logger('ActiveWindow');

  final _settings = Preferences.instance;

  /// Nyrna's own PID.
  final int nyrnaPid = io.pid;

  late int? id;

  late int pid;

  @visibleForTesting
  Future<void> initialize() async {
    pid = await _nativePlatform.activeWindowPid;
    await _verifyPid();
    id = await _nativePlatform.activeWindowId;
  }

  /// Hide the Nyrna window.
  ///
  /// Necessary when using the toggle active window feature,
  /// until Flutter has a way to run without GUI.
  Future<void> _hideNyrna() async {
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
      ['getactivewindow', 'windowminimize', '--sync'],
    );
  }

  /// Hide own window using the win32 API.
  Future<void> _hideWindows() async {
    var id = GetForegroundWindow();
    // We would prefer SW_HIDE, however that leaves Nyrna still
    // considered the foreground window. So, minimize instead.
    ShowWindow(id, SW_FORCEMINIMIZE);
  }

  Future<void> _verifyPid() async {
    // Verify active window wasn't Nyrna.
    // This _could_ happen because we have to hide Nyrna's window instead of
    // just not running the GUI for now. Sanity check: don't suspend self.
    if (pid == nyrnaPid) {
      _log.severe("Active window PID was Nyrna's own, exiting.");
      if (ArgumentParser.logToFile) await LogFile.instance.write();
      io.exit(1);
    }
    if (_settings.savedProcess != 0) await _checkStillExists();
  }

  /// Check that saved process still exists.
  Future<void> _checkStillExists() async {
    final savedPid = _settings.savedProcess;
    final savedProcess = Process(savedPid);
    final exists = await savedProcess.exists();
    if (!exists) {
      await _removeSavedProcess();
      _log.warning('Saved pid no longer exists, removed.');
      if (ArgumentParser.logToFile) await LogFile.instance.write();
      io.exit(0);
    }
  }

  /// Toggle the suspend / resume state of the given process.
  Future<bool> _toggleProcess() async {
    if (_settings.savedProcess != 0) {
      final successful = await _resume();
      return successful;
    } else {
      final successful = await _suspend();
      return successful;
    }
  }

  Future<bool> _resume() async {
    var successful = false;
    pid = _settings.savedProcess;
    id = _settings.savedWindowId;
    final process = Process(pid);
    final _status = await process.status;
    if (_status == ProcessStatus.unknown) {
      await _removeSavedProcess();
      _log.warning('Issue getting status, removed saved process.');
    }
    if (_status == ProcessStatus.suspended) {
      successful = await process.toggle();
      await _removeSavedProcess();
      if (!successful) {
        _log.warning('Failed to resume PID: $pid');
        return successful;
      }
      await _windowControls.restore(id);
    }
    return successful;
  }

  Future<void> _removeSavedProcess() async {
    await _settings.setSavedProcess(0);
    await _settings.setSavedWindowId(0);
  }

  Future<bool> _suspend() async {
    var successful = false;
    final process = Process(pid);
    await _windowControls.minimize(id);
    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    successful = await process.toggle();
    await _settings.setSavedProcess(pid);
    await _settings.setSavedWindowId(id!);
    if (!successful) {
      _log.warning('Failed to suspend PID: $pid');
    }
    return successful;
  }

  /// Toggle suspend / resume for the active, foreground window.
  Future<void> toggle() async {
    final _log = Logger('toggleActiveWindow');
    _log.info('toggleActiveWindow beginning');
    await _hideNyrna();
    await initialize();
    final successful = await _toggleProcess();
    if (!successful) {
      await _removeSavedProcess();
      _log.warning('Failed to toggle active window. Cleared saved pid.');
    }
    _log.info('Finished toggle window, exiting.');
    if (ArgumentParser.logToFile) await LogFile.instance.write();
    // Not yet possible to run without GUI, so we just exit after toggling.
    io.exit(0);
  }
}
