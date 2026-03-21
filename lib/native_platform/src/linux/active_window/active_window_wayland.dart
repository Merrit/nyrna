import 'dart:async';
import 'dart:convert';

import '../../../../logs/logging_manager.dart';
import '../../../native_platform.dart';
import '../linux.dart';

class ActiveWindowWayland {
  /// KWin script name used to load / unload the persistent active-window
  /// listener script.
  static const String kdeScriptName = 'nyrna_get_active_window';

  /// Subscription to D-Bus active-window update events.
  ///
  /// Set by [initialize] and cancelled by [dispose].
  static StreamSubscription<String>? _subscription;

  /// Subscribe to [NyrnaDbus.activeWindowUpdates] so that every focus change
  /// reported by the persistent KWin script immediately updates
  /// [Linux.activeWindow].
  ///
  /// Must be called once from [Linux.initialize] after the KWin scripts have
  /// been loaded.
  static void initialize(Linux linux) {
    log.i('Setting up persistent active-window subscription (KDE Wayland).');
    _subscription = linux.nyrnaDbus.activeWindowUpdates.listen(
      (windowString) async {
        log.t('Active window update: $windowString');
        final windowJson = jsonDecode(windowString);
        final pid = int.tryParse(windowJson['pid'].toString());
        if (pid == null) return;
        final executable = await linux.getExecutableName(pid);

        final process = Process(
          pid: pid,
          executable: executable,
          status: ProcessStatus.unknown,
        );

        final window = Window(
          id: windowJson['internalId'].toString(),
          process: process,
          title: windowJson['caption'].toString(),
        );

        linux.activeWindow = window;
      },
    );
  }

  /// Cancel the active-window subscription.
  ///
  /// Called from [Linux.dispose].
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Ensure [linux.activeWindow] is populated.
  ///
  /// Because the persistent KWin listener keeps [Linux.activeWindow] up-to-date
  /// in the background, this method simply waits (up to [_timeout]) for the
  /// field to become non-null.  For X11 the field is set synchronously by
  /// [ActiveWindowX11.fetch], so the wait is skipped immediately.
  static const Duration _timeout = Duration(seconds: 2);
  static const Duration _pollInterval = Duration(milliseconds: 100);

  static Future<void> fetch(Linux linux) async {
    switch (linux.sessionType.environment) {
      case DesktopEnvironment.kde:
        await _waitForActiveWindow(linux);
      case DesktopEnvironment.gnome:
        // TODO: A GNOME Shell extension approach would be needed for GNOME Wayland.
        throw UnimplementedError('GNOME Wayland support is not yet implemented');
      default:
        throw UnimplementedError(
          'ActiveWindowWayland.fetch is not implemented for '
          '${linux.sessionType.environment}',
        );
    }
  }

  static Future<void> _waitForActiveWindow(Linux linux) async {
    if (linux.activeWindow != null) return;

    log.d('Waiting for active window to be populated by KDE Wayland listener…');
    final deadline = DateTime.now().add(_timeout);
    while (linux.activeWindow == null && DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);
    }

    if (linux.activeWindow == null) {
      log.w('Timed out waiting for active window from KDE Wayland listener.');
    }
  }
}
