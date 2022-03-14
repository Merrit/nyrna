import 'dart:io';

import 'package:active_window/src/storage.dart';
import 'package:hive/hive.dart';
import 'package:native_platform/native_platform.dart';

import '../active_window.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow({
  bool shouldLog = false,
  required NativePlatform nativePlatform,
}) async {
  Logger.shouldLog = shouldLog;
  Hive.init(Directory.systemTemp.path);
  final storage = Storage();

  final activeWindow = ActiveWindow(
    await nativePlatform.activeWindow(),
    nativePlatform,
    storage,
  );

  final savedPid = await storage.getInt('pid');

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) await Logger.log('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) await Logger.log('Failed to suspend successfully.');
  }

  await Hive.close();
}
