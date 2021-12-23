import 'dart:io';

import 'package:hive/hive.dart';
import 'package:native_platform/native_platform.dart';

import '../active_window.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow({bool logToFile = false}) async {
  Logger.shouldLog = logToFile;

  Hive.init(Directory.systemTemp.path);

  final nativePlatform = NativePlatform();

  final activeWindow = ActiveWindowHandler(nativePlatform);

  final savedPid = await activeWindow.savedPid();

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) await Logger.log('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) await Logger.log('Failed to suspend successfully.');
  }

  await Hive.close();
}
