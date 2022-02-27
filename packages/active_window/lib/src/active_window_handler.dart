import 'dart:io';

import 'package:hive/hive.dart';
import 'package:native_platform/native_platform.dart';

import 'logger.dart';

class ActiveWindowHandler {
  final NativePlatform _nativePlatform;

  const ActiveWindowHandler(this._nativePlatform);

  /// Get a value from Hive.
  Future<int?> _getSavedValue(String key) async {
    final box = await Hive.openBox('saved');
    var value = box.get(key);
    if (value != null) value = value as int;
    return value;
  }

  /// Save a value to Hive.
  Future<void> _saveValue({
    required String key,
    required int value,
  }) async {
    final box = await Hive.openBox('saved');
    await box.put(key, value);
  }

  /// Delete the saved information, so the next run will suspend.
  Future<void> _deleteSaved() async => await Hive.deleteBoxFromDisk('saved');

  Future<int?> savedPid() async => await _getSavedValue('pid');

  Future<bool> resume(int pid) async {
    await Logger.log('resuming, pid: $pid');
    final window = await _nativePlatform.activeWindow();
    final executable = window.executable;
    final process = Process(pid: pid, executable: executable);
    final resumed = await process.resume();
    if (!resumed) {
      await Logger.log('Failed to resume! Try resuming process manually?');
      await _deleteSaved(); // Must delete here, or enter infinite loop of failing to resume.
      return false;
    }
    final windowId = await _getSavedValue('windowId');
    await _deleteSaved();
    if (windowId == null) {
      await Logger.log('Failed to find saved windowId, cannot restore.');
    } else {
      final restored = await _nativePlatform.restoreWindow(windowId);
      if (!restored) await Logger.log('Failed to restore window.');
    }
    await Logger.log('Resumed $pid successfully.');
    return true;
  }

  Future<bool> suspend() async {
    await Logger.log('Suspending');
    var activeWindow = await _nativePlatform.activeWindow();
    if (Platform.isWindows) {
      // Once in a blue moon on Windows we get "explorer.exe" as the active
      // window, even when no file explorer windows are open / the desktop
      // is not the active element, etc. So we filter it just in case.
      final executable = activeWindow.executable;
      if (executable == 'explorer.exe') {
        await Logger.log('Only got explorer as active window!');
        return false;
      }
    }
    final minimized = await activeWindow.minimize();
    if (!minimized) {
      await Logger.log('Failed to minimize window.');
      return false;
    }
    // Small delay on Windows to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    final suspended = await activeWindow.suspend();
    if (!suspended) {
      await Logger.log('Failed to suspend active window.');
      return false;
    }
    await _saveValue(key: 'pid', value: activeWindow.pid);
    await _saveValue(key: 'windowId', value: activeWindow.id);
    await Logger.log('Suspended ${activeWindow.pid} successfully');
    return true;
  }
}
