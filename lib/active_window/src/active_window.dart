import 'package:flutter/foundation.dart';

import '../../argument_parser/argument_parser.dart';
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
    log.i('Toggling active window.');

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

    return successful;
  }

  Future<bool> _resume(int savedPid) async {
    log.i('resuming, pid: $savedPid');

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

    log.i('Resumed $savedPid successfully.');

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
    log.i('Suspending');

    final window = await _nativePlatform.activeWindow();

    final String executable = window.process.executable;
    if (executable == 'nyrna' || executable == 'nyrna.exe') {
      log.w('Active window is Nyrna, not suspending.');
      return false;
    }

    log.i('Active window: $window');

    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Once in a blue moon on Windows we get "explorer.exe" as the active
      // window, even when no file explorer windows are open / the desktop
      // is not the active element, etc. So we filter it just in case.
      if (window.process.executable == 'explorer.exe') {
        log.e('Only got explorer as active window!');
        return false;
      }
    }

    await _minimize(window.id);

    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final suspended = await _processRepository.suspend(window.process.pid);
    if (!suspended) {
      log.e('Failed to suspend active window.');
      return false;
    }

    await _storageRepository.saveValue(
      key: 'pid',
      value: window.process.pid,
      storageArea: 'activeWindow',
    );
    await _storageRepository.saveValue(
      key: 'windowId',
      value: window.id,
      storageArea: 'activeWindow',
    );
    log.i('Suspended ${window.process.pid} successfully');

    return true;
  }

  Future<void> _minimize(int windowId) async {
    final shouldMinimize = await _getShouldMinimize();
    if (!shouldMinimize) return;

    log.i('Starting minimize');
    final minimized = await _nativePlatform.minimizeWindow(windowId);
    if (!minimized) log.e('Failed to minimize window.');
  }

  Future<void> _restore(int windowId) async {
    final shouldRestore = await _getShouldMinimize();
    if (!shouldRestore) return;

    log.i('Starting restore');
    final minimized = await _nativePlatform.restoreWindow(windowId);
    if (!minimized) log.e('Failed to restore window.');
  }

  /// Checks for a user preference on whether to minimize/restore windows.
  Future<bool> _getShouldMinimize() async {
    // If minimize preference was set by flag it overrides UI-based preference.
    final minimizeArg = ArgumentParser.instance.minimize;
    if (minimizeArg != null) {
      log.i('Received no-minimize flag, affecting window state: $minimizeArg');
      return minimizeArg;
    }

    bool? minimize = await _storageRepository.getValue('minimizeWindows');
    minimize ??= true;
    log.i('Minimizing / restoring window: $minimize');
    return minimize;
  }
}
