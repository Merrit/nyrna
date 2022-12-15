import 'package:flutter/foundation.dart';

import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';

/// Manage the active window.
///
/// We use extra logging here in order to debug issues since this has
/// no user interface.
class ActiveWindow {
  final NativePlatform _nativePlatform;
  final ProcessRepository _processRepository;
  final StorageRepository _storageRepository;

  const ActiveWindow(
    this._nativePlatform,
    this._processRepository,
    this._storageRepository,
  );

  /// Toggle suspend / resume for the active, foreground window.
  Future<bool> toggle() async {
    log.v('Toggling active window.');

    final savedPid = await _storageRepository.getValue(
      'pid',
      storageArea: 'activeWindow',
    );

    bool successful;
    if (savedPid != null) {
      successful = await _resume(savedPid);
      if (!successful) log.e('Failed to resume successfully.');
    } else {
      successful = await _suspend();
      if (!successful) log.e('Failed to suspend successfully.');
    }

    await _storageRepository.close();
    LoggingManager.instance.close();
    // Add a slight delay, because Logger doesn't await closing its file output.
    // This will hopefully ensure the log file gets fully written.
    await Future.delayed(const Duration(milliseconds: 500));

    return successful;
  }

  Future<bool> _resume(int savedPid) async {
    log.v('resuming, pid: $savedPid');

    final resumed = await _processRepository.resume(savedPid);
    if (!resumed) {
      log.e('Failed to resume! Try resuming process manually?');
      // Must delete here, or enter infinite loop of failing to resume.
      await _deleteSavedIds();
      return false;
    }

    final windowId = await _storageRepository.getValue(
      'windowId',
      storageArea: 'activeWindow',
    );
    await _deleteSavedIds();
    if (windowId == null) {
      log.e('Failed to find saved windowId, cannot restore.');
    } else {
      await _restore(windowId);
    }

    log.v('Resumed $savedPid successfully.');

    return true;
  }

  Future<void> _deleteSavedIds() async {
    await _storageRepository.deleteValue('pid', storageArea: 'activeWindow');
    await _storageRepository.deleteValue(
      'windowId',
      storageArea: 'activeWindow',
    );
  }

  Future<bool> _suspend() async {
    log.v('Suspending');

    final _window = await _nativePlatform.activeWindow();

    log.v('Active window: $_window');

    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Once in a blue moon on Windows we get "explorer.exe" as the active
      // window, even when no file explorer windows are open / the desktop
      // is not the active element, etc. So we filter it just in case.
      if (_window.process.executable == 'explorer.exe') {
        log.e('Only got explorer as active window!');
        return false;
      }
    }

    await _minimize(_window.id);

    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final suspended = await _processRepository.suspend(_window.process.pid);
    if (!suspended) {
      log.e('Failed to suspend active window.');
      return false;
    }

    await _storageRepository.saveValue(
      key: 'pid',
      value: _window.process.pid,
      storageArea: 'activeWindow',
    );
    await _storageRepository.saveValue(
      key: 'windowId',
      value: _window.id,
      storageArea: 'activeWindow',
    );
    log.v('Suspended ${_window.process.pid} successfully');

    return true;
  }

  Future<void> _minimize(int windowId) async {
    log.v('Starting minimize');
    final shouldMinimize = await _getShouldMinimize();
    if (!shouldMinimize) return;

    final minimized = await _nativePlatform.minimizeWindow(windowId);
    if (!minimized) log.e('Failed to minimize window.');
  }

  Future<void> _restore(int windowId) async {
    final shouldRestore = await _getShouldMinimize();
    if (!shouldRestore) return;

    final minimized = await _nativePlatform.restoreWindow(windowId);
    if (!minimized) log.e('Failed to restore window.');
  }

  /// Checks for a user preference on whether to minimize/restore windows.
  Future<bool> _getShouldMinimize() async {
    return await _storageRepository.getValue('minimizeWindows') ?? true;
  }
}
