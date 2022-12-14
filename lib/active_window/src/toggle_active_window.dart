import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../storage/storage_repository.dart';
import 'active_window.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<bool> toggleActiveWindow(
  NativePlatform nativePlatform,
  ProcessRepository processRepository,
  StorageRepository storageRepository,
) async {
  log.v('Toggling active window.');

  final activeWindow = ActiveWindow(
    nativePlatform,
    processRepository,
    storageRepository,
    await nativePlatform.activeWindow(),
  );

  final savedPid = await storageRepository.getValue(
    'pid',
    storageArea: 'activeWindow',
  );

  bool successful;
  if (savedPid != null) {
    successful = await activeWindow.resume(savedPid);
    if (!successful) log.e('Failed to resume successfully.');
  } else {
    successful = await activeWindow.suspend();
    if (!successful) log.e('Failed to suspend successfully.');
  }

  await storageRepository.close();
  LoggingManager.instance.close();
  // Add a slight delay, because Logger doesn't await closing its file output.
  // This will hopefully ensure the log file gets fully written.
  await Future.delayed(const Duration(milliseconds: 500));

  return successful;
}
