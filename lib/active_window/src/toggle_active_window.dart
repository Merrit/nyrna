import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';
import 'active_window.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow(
  NativePlatform nativePlatform,
  StorageRepository storageRepository,
) async {
  final activeWindow = ActiveWindow(
    nativePlatform,
    ProcessRepository.init(),
    storageRepository,
    await nativePlatform.activeWindow(),
  );

  final savedPid = await storageRepository.getValue(
    'pid',
    storageArea: 'activeWindow',
  );

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) log.e('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) log.e('Failed to suspend successfully.');
  }

  await storageRepository.close();
  LoggingManager.instance.close();
  // Add a slight delay, because Logger doesn't await closing its file output.
  // This will hopefully ensure the log file gets fully written.
  await Future.delayed(const Duration(milliseconds: 500));
}
