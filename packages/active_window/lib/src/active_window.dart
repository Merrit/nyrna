import 'dart:io';

import 'package:native_platform/native_platform.dart';

import 'logger.dart';
import 'storage.dart';

/// Manage the active window.
///
/// We use extra logging here in order to debug issues since this has
/// no user interface.
class ActiveWindow {
  final NativePlatform nativePlatform;
  final Storage _storage;
  final Window _window;

  const ActiveWindow(this._window, this.nativePlatform, this._storage);

  Future<bool> resume(int savedPid) async {
    await Logger.log('resuming, pid: $savedPid');

    final process = Process(pid: savedPid, executable: '');

    final resumed = await process.resume();
    if (!resumed) {
      await Logger.log('Failed to resume! Try resuming process manually?');
      // Must delete here, or enter infinite loop of failing to resume.
      await _storage.deleteSaved();
      return false;
    }

    final windowId = await _storage.getInt('windowId');
    await _storage.deleteSaved();
    if (windowId == null) {
      await Logger.log('Failed to find saved windowId, cannot restore.');
    } else {
      final restoreSuccessful = await nativePlatform.restoreWindow(windowId);
      if (!restoreSuccessful) await Logger.log('Failed to restore window.');
    }

    await Logger.log('Resumed $savedPid successfully.');

    return true;
  }

  Future<bool> suspend() async {
    await Logger.log('Suspending');

    if (Platform.isWindows) {
      // Once in a blue moon on Windows we get "explorer.exe" as the active
      // window, even when no file explorer windows are open / the desktop
      // is not the active element, etc. So we filter it just in case.
      if (_window.process.executable == 'explorer.exe') {
        await Logger.log('Only got explorer as active window!');
        return false;
      }
    }

    final minimized = await nativePlatform.minimizeWindow(_window.id);
    if (!minimized) {
      await Logger.log('Failed to minimize window.');
      return false;
    }

    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    final suspended = await _window.process.suspend();
    if (!suspended) {
      await Logger.log('Failed to suspend active window.');
      return false;
    }

    await _storage.saveValue(key: 'pid', value: _window.process.pid);
    await _storage.saveValue(key: 'windowId', value: _window.id);
    await Logger.log('Suspended ${_window.process.pid} successfully');

    return true;
  }
}
