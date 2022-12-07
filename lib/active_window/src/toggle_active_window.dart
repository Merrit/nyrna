import 'package:hive/hive.dart';

import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import 'active_window.dart';
import 'storage.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow({
  required NativePlatform nativePlatform,
}) async {
  final storage = Storage();

  final activeWindow = ActiveWindow(
    nativePlatform,
    ProcessRepository.init(),
    storage,
    await nativePlatform.activeWindow(),
  );

  final savedPid = await storage.getInt('pid');

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) log.e('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) log.e('Failed to suspend successfully.');
  }

  await Hive.close();
  LoggingManager.instance.close();
  // Add a slight delay, because Logger doesn't await closing its file output.
  // This will hopefully ensure the log file gets fully written.
  await Future.delayed(const Duration(milliseconds: 500));
}
