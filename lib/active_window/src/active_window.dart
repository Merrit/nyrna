import 'dart:io' hide pid;

import '../../native_platform/native_platform.dart';
import 'logger.dart';
import 'storage.dart';

/// Manage the active window.
///
/// We use extra logging here in order to debug issues since this has
/// no user interface.
class ActiveWindow {
  final NativePlatform _nativePlatform;
  final ProcessRepository _processRepository;
  final Storage _storage;
  final Window _window;

  const ActiveWindow(
    this._nativePlatform,
    this._processRepository,
    this._storage,
    this._window,
  );

  Future<bool> resume(int savedPid) async {
    await Logger.log('resuming, pid: $savedPid');

    final resumed = await _processRepository.resume(savedPid);
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
      final restoreSuccessful = await _nativePlatform.restoreWindow(windowId);
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

    final minimized = await _nativePlatform.minimizeWindow(_window.id);
    if (!minimized) {
      await Logger.log('Failed to minimize window.');
      return false;
    }

    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (Platform.isWindows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final suspended = await _processRepository.suspend(_window.process.pid);
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
