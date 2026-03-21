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
      final activeWindowScriptPath = await _getActiveWindowKdeScriptPath();

      // Derive the host-visible script directory from the already-resolved
      // script path (both scripts live in the same app-support directory).
      // Falls back to empty string in tests, which causes Linux to use the
      // system temp directory (acceptable outside Flatpak).
      final tempScriptDir = kdeWaylandScriptPath.isNotEmpty
          ? io.File(kdeWaylandScriptPath).parent.path
          : '';

      return await Linux.initialize(
        runFunction,
        kdeWaylandScriptPath: kdeWaylandScriptPath,
        activeWindowScriptPath: activeWindowScriptPath,
        tempScriptDir: tempScriptDir,
      );
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
  Future<void> checkActiveWindow();

  /// Verify dependencies are present on the system.
  Future<bool> checkDependencies();

  /// Minimize the window with the given [windowId].
  Future<bool> minimizeWindow(String windowId);

  /// Restore / unminimize the window with the given [windowId].
  Future<bool> restoreWindow(String windowId);

  /// Safely dispose of resources when done.
  Future<void> dispose();

  /// The session type of the current platform, if applicable.
  ///
  /// Returns `null` on non-Linux platforms.
  SessionType? get sessionType => null;
}

/// Get the path to the KDE Wayland script.
///
/// The script will be kept in the application support directory so we can provide the
/// path to it over D-Bus, which can't be done when the script is in the app bundle.
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

/// Get the path to the persistent active-window KDE KWin script.
///
/// Copies the bundled asset to the application support directory so that KWin
/// can be given a filesystem path via D-Bus.  The file is overwritten on every
/// launch to keep it in sync with the bundled version.
Future<String> _getActiveWindowKdeScriptPath() async {
  if (io.Platform.environment['FLUTTER_TEST'] == 'true') return '';

  final dataDir = await getApplicationSupportDirectory();
  final tempFile = await assetToTempDir('assets/lib/linux/active_window_kde.js');
  final file = io.File('${dataDir.path}${io.Platform.pathSeparator}active_window_kde.js');
  await tempFile.copy(file.path);
  return file.path;
}
