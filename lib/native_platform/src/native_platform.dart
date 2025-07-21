import 'dart:io' as io;

import 'package:helpers/helpers.dart';
import 'package:path_provider/path_provider.dart';

import 'linux/linux.dart';
import 'win32/win32.dart';
import 'window.dart';

/// Interact with the native operating system.
///
/// Abstract class bridges types for specific operating systems.
/// Used by [Linux] and [Win32].
abstract class NativePlatform {
  // Return correct subtype depending on the current operating system.
  static Future<NativePlatform> initialize() async {
    if (io.Platform.isLinux) {
      final runFunction = (runningInFlatpak()) ? flatpakRun : io.Process.run;
      final kdeWaylandScriptPath = await _getKdeWaylandScriptPath();
      return await Linux.initialize(runFunction, kdeWaylandScriptPath);
    } else {
      return Win32();
    }
  }

  /// The index of the currently active virtual desktop.
  Future<int> currentDesktop();

  /// List of [Window] objects for every visible window with title text.
  ///
  /// Setting [showHidden] to `true` will list windows from every
  /// virtual desktop, as well as some that might be mistakenly cloaked.
  Future<List<Window>> windows({bool showHidden});

  /// The active, foreground window.
  Window? activeWindow;

  /// Update our knowledge of the active window.
  ///
  /// Active window will be emitted on the [activeWindowStream].
  Future<void> checkActiveWindow();

  /// Stream of the active window.
  Stream<Window> get activeWindowStream;

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();

  /// Minimize the window with the given [windowId].
  Future<bool> minimizeWindow(String windowId);

  /// Restore / unminimize the window with the given [windowId].
  Future<bool> restoreWindow(String windowId);

  /// Safely dispose of resources when done.
  Future<void> dispose();
}

/// Get the path to the KDE Wayland script.
///
/// The script will be kept in the application support directory so we can provide the
/// path to it over D-Bus, which can't be done whhen the script is in the app bundle.
///
/// The script will be copied over on every launch to ensure it's up-to-date.
Future<String> _getKdeWaylandScriptPath() async {
  if (io.Platform.environment['FLUTTER_TEST'] == 'true') return '';

  final dataDir = await getApplicationSupportDirectory();
  final tempFile = await assetToTempDir('assets/lib/linux/list_windows_kde.js');
  final file = io.File('${dataDir.path}${io.Platform.pathSeparator}list_windows_kde.js');
  await tempFile.copy(file.path);
  return file.path;
}
