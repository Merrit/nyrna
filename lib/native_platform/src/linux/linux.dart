import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:kwin/kwin.dart';

import '../../../logs/logs.dart';
import '../native_platform.dart';
import '../process/models/process.dart';
import '../typedefs.dart';
import '../window.dart';
import 'active_window/active_window_service.dart';
import 'active_window/active_window_wayland.dart';
import 'dbus/nyrna_dbus.dart';
import 'session_type.dart';

export 'flatpak.dart';
export 'session_type.dart';

/// System-level or non-app executables. Nyrna shouldn't show these.
const List<String> _filteredWindows = [
  'nyrna',
  // Remove any instances of plasmashell, which is the KDE desktop.
  // It appears to show up for each monitor and virtual desktop.
  'plasmashell',
  'xwaylandvideobridge',
];

/// Interact with the native Linux operating system.
class Linux implements NativePlatform {
  /// Name of the KWin script that fetches info when running KDE Wayland.
  static const String _kdeWaylandScriptName = 'nyrna_wayland';

  /// Path to the KWin script that fetches info when running KDE Wayland.
  ///
  /// The path is an argument to allow for dependency injection in tests.
  final String _kdeWaylandScriptPath;

  /// Path to the persistent active-window KWin script for KDE Wayland.
  ///
  /// The path is an argument to allow for dependency injection in tests.
  final String _activeWindowScriptPath;

  /// Directory in which temporary KWin scripts (minimize/restore) are written.
  ///
  /// Must be a path that is accessible to KWin on the host filesystem.  In a
  /// Flatpak sandbox the system temp directory is private to the container, so
  /// the application-support directory (visible to the host via bind-mount) is
  /// used instead.  Defaults to [io.Directory.systemTemp] when empty.
  final String _tempScriptDir;

  final KWin kwin;
  final NyrnaDbus nyrnaDbus;
  final RunFunction _run;

  @override
  final SessionType sessionType;
  StreamSubscription<String>? _scriptOutputSubscription;
  Linux._(
    this._kdeWaylandScriptPath,
    this._activeWindowScriptPath,
    this._tempScriptDir,
    this.kwin,
    this.nyrnaDbus,
    this._run,
    this.sessionType,
  );

  @override
  Window? activeWindow;

  static Future<Linux> initialize(
    RunFunction run, {
    String kdeWaylandScriptPath = '',
    String activeWindowScriptPath = '',
    KWin? kwin, // Allows overriding for testing.
    NyrnaDbus? nyrnaDbus, // Allows overriding for testing.
    SessionType? sessionOverride, // Allows overriding for testing.
    String tempScriptDir = '',
  }) async {
    final dbusService = nyrnaDbus ?? await NyrnaDbus.initialize();
    final kwinService = kwin ?? KWin();
    final session = sessionOverride ?? await SessionType.fromEnvironment();
    final linux = Linux._(
      kdeWaylandScriptPath,
      activeWindowScriptPath,
      tempScriptDir,
      kwinService,
      dbusService,
      run,
      session,
    );

    if (session.displayProtocol == DisplayProtocol.wayland &&
        session.environment == DesktopEnvironment.kde) {
      ActiveWindowWayland.initialize(linux);
      await linux._loadKdeWaylandScript();
    }

    return linux;
  }

  Future<void> _loadKdeWaylandScript() async {
    log.i('Loading KWin scripts for KDE Wayland.');
    log.i('  List-windows script: $_kdeWaylandScriptPath');
    log.i('  Active-window script: $_activeWindowScriptPath');

    await kwin.loadScript(_kdeWaylandScriptPath, _kdeWaylandScriptName);
    await kwin.loadScript(_activeWindowScriptPath, ActiveWindowWayland.kdeScriptName);

    // Log KWin script output prefixed by 'Nyrna'.
    _scriptOutputSubscription = kwin.scriptOutput
        .where((event) => event.contains('Nyrna'))
        .listen((event) {
          log.t('KWin script output: $event');
        });

    // Poll until the KWin list-windows script has populated the window list,
    // so the UI is not shown before data is ready.  Using a polling loop
    // instead of a fixed delay allows the UI to appear as soon as the scripts
    // respond, and avoids unnecessary waiting when KWin is fast.
    const scriptTimeout = Duration(seconds: 5);
    const pollInterval = Duration(milliseconds: 100);
    final deadline = DateTime.now().add(scriptTimeout);
    while (nyrnaDbus.windowsJson.isEmpty && DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);
    }
    if (nyrnaDbus.windowsJson.isEmpty) {
      log.w('Timed out waiting for KWin script to populate the window list.');
    }
  }

  int? _desktop;

  // Active virtual desktop as reported by wmctrl.
  @override
  Future<int> currentDesktop() async {
    final result = await _run('wmctrl', ['-d']);
    final lines = result.stdout.toString().split('\n');
    for (var line in lines) {
      if (line.contains('*')) _desktop = int.tryParse(line[0]);
    }
    _desktop ??= 0;
    return _desktop ?? 0;
  }

  // Gets all open windows as reported by wmctrl.
  @override
  Future<List<Window>> windows({bool showHidden = false}) async {
    switch (sessionType.displayProtocol) {
      case DisplayProtocol.wayland:
        return await _getWindowsWayland(showHidden);
      case DisplayProtocol.x11:
        return await _getWindowsX11(showHidden);
      default:
        return Future.error('Unknown session type: $sessionType');
    }
  }

  Future<List<Window>> _getWindowsWayland(bool showHidden) async {
    switch (sessionType.environment) {
      case DesktopEnvironment.kde:
        return await _getWindowsKdeWayland(showHidden);
      default:
        // For non-KDE Wayland (GNOME, etc.), fall back to X11 detection
        // so xwayland apps are still visible.
        log.w(
          'Wayland on ${sessionType.environment} is not natively supported. '
          'Falling back to X11 detection for xwayland apps.',
        );
        return await _getWindowsX11(showHidden);
    }
  }

  Future<List<Window>> _getWindowsKdeWayland(bool showHidden) async {
    if (nyrnaDbus.windowsJson.isEmpty) {
      log.w('No windows found from KDE Wayland');
      return [];
    }

    final windowsJson = jsonDecode(nyrnaDbus.windowsJson);
    final windows = <Window>[];

    for (var window in windowsJson) {
      final onCurrentDesktop = window['onCurrentDesktop'] == true;
      if (!onCurrentDesktop && !showHidden) continue;

      final windowId = window['internalId'];
      final windowTitle = window['caption'];
      final pid = window['pid'];
      final executable = await getExecutableName(pid);
      if (_filteredWindows.contains(executable)) continue;

      final process = Process(
        pid: pid,
        executable: executable,
        status: ProcessStatus.unknown,
      );

      windows.add(
        Window(
          id: windowId,
          process: process,
          title: windowTitle,
        ),
      );
    }

    log.i('Windows from KDE Wayland: found ${windows.length} windows');

    return windows;
  }

  Future<List<Window>> _getWindowsX11(bool showHidden) async {
    await currentDesktop();

    final wmctrlOutput = await _run('bash', ['-c', 'wmctrl -lp']);

    // Each line from wmctrl will be something like:
    // 0x03600041  1 1459   SHODAN Inbox - Unified Folders - Mozilla Thunderbird
    // windowId, desktopId, pid, user, window title
    final lines = wmctrlOutput.stdout.toString().split('\n');

    final windows = <Window>[];

    for (var line in lines) {
      final window = await _buildWindow(line, showHidden);
      if (window != null) windows.add(window);
    }

    return windows;
  }

  /// wmctrl reports a window's desktop number as -1 if it is "sticky".
  /// For example, if using GNOME's "Workspaces on primary display only"
  /// preference every window on secondary displays will have "desktop: -1";
  static const _kStickyWindowIdentifier = -1;

  /// Takes a line of output from wmctrl and if valid returns a [Window].
  Future<Window?> _buildWindow(String wmctrlLine, bool showHidden) async {
    final parts = wmctrlLine.split(' ');
    parts.removeWhere((part) => part == ''); // Happens with multiple spaces.

    if (parts.length < 2) return null;

    // Which virtual desktop this window is on.
    final windowDesktop = int.tryParse(parts[1]);
    final windowOnCurrentDesktop =
        (windowDesktop == _desktop || windowDesktop == _kStickyWindowIdentifier);
    if (!windowOnCurrentDesktop && !showHidden) return null;

    final pid = int.tryParse(parts[2]);
    final id = int.tryParse(parts[0]);
    if ((pid == null) || (id == null)) return null;

    final executable = await getExecutableName(pid);
    if (_filteredWindows.contains(executable)) return null;

    final process = Process(
      executable: executable,
      pid: pid,
      status: ProcessStatus.unknown,
    );
    final title = parts.sublist(4).join(' ');

    return Window(id: '$id', process: process, title: title);
  }

  Future<String> getExecutableName(int pid) async {
    final result = await _run('readlink', ['/proc/$pid/exe']);
    final executable = result.stdout.toString().split('/').last.trim();
    return executable;
  }

  @override
  Future<void> checkActiveWindow() async {
    final activeWindowService = ActiveWindowService(this, _run);
    await activeWindowService.fetch();
  }

  // Verify required tools are present on the system.
  @override
  Future<bool> checkDependencies() async {
    if (sessionType.displayProtocol == DisplayProtocol.wayland &&
        sessionType.environment == DesktopEnvironment.kde) {
      // KDE Wayland uses KWin D-Bus scripting.  If initialization succeeded,
      // the interface is available; no additional binary dependencies to check.
      return true;
    }

    // X11 (or unknown protocol) — verify wmctrl and xdotool are present.
    final xdotoolResult = await _run('bash', [
      '-c',
      'command -v xdotool >/dev/null 2>&1 || { echo >&2 "xdotool is required but it\'s not installed."; exit 1; }',
    ]);

    final wmctrlResult = await _run('bash', [
      '-c',
      'command -v wmctrl >/dev/null 2>&1 || { echo >&2 "wmctrl is required but it\'s not installed."; exit 1; }',
    ]);

    final xdotoolAvailable = xdotoolResult.stderr.toString().trim() == '';
    final wmctrlAvailable = wmctrlResult.stderr.toString().trim() == '';
    final dependenciesAvailable = xdotoolAvailable && wmctrlAvailable;

    if (!dependenciesAvailable) {
      log.e(
        '''
Dependency check failed!
xdotool available: $xdotoolAvailable
wmctrl available: $wmctrlAvailable
Make sure these are installed on your host system.''',
      );
    }

    return dependenciesAvailable;
  }

  @override
  Future<bool> minimizeWindow(String windowId) async {
    log.i('Minimizing window with id $windowId');

    switch (sessionType.displayProtocol) {
      case DisplayProtocol.wayland:
        switch (sessionType.environment) {
          case DesktopEnvironment.kde:
            return await _minimizeWindowWaylandKDE(windowId);
          default:
            // For non-KDE Wayland (e.g. GNOME), window listing falls back to
            // X11/wmctrl, so window IDs are X11 integers — use xdotool.
            return await _minimizeWindowX11(windowId);
        }
      case DisplayProtocol.x11:
        return await _minimizeWindowX11(windowId);
      default:
        return Future.error('Unknown session type: $sessionType.displayProtocol');
    }
  }

  Future<bool> _minimizeWindowX11(String windowId) async {
    final result = await _run(
      'xdotool',
      ['windowminimize', windowId],
    );
    return (result.stderr == '') ? true : false;
  }

  static const String kwinMinimizeRestoreScript = '''
(function() {
    function print(str) {
        console.info('Nyrna: ' + str);
    }

    let windows = workspace.windowList();
    let targetWindowId = "%windowId%";
    // Normalize UUIDs by stripping curly braces to handle format differences
    // between JSON.stringify() and QUuid.toString() in KWin's JS engine.
    let normalizeId = (id) => id.toString().replace(/[{}]/g, '').toLowerCase();
    let targetNormalized = normalizeId(targetWindowId);
    let targetWindow = windows.find(w => normalizeId(w.internalId) === targetNormalized);

    if (!targetWindow) {
        print('Window with id ' + targetWindowId + ' not found');
        return;
    }

    let shouldMinimize = %minimize%;
    targetWindow.minimized = shouldMinimize;

    print('Window with id ' + targetWindowId + ' ' + (shouldMinimize ? 'minimized' : 'restored'));

    if (!shouldMinimize) {
        workspace.activeWindow = targetWindow;
    }
})();
''';

  Future<bool> _minimizeWindowWaylandKDE(String windowId) async {
    if (!_isValidWindowId(windowId)) {
      log.e('Invalid windowId for minimize: $windowId');
      return false;
    }

    // Create a javascript file in a host-visible directory so KWin can load it.
    // The system temp directory is private to the Flatpak sandbox, so we use
    // _tempScriptDir (the application-support directory) instead when set.
    final scriptDir = _tempScriptDir.isNotEmpty
        ? _tempScriptDir
        : io.Directory.systemTemp.path;
    final scriptFile = io.File('$scriptDir/nyrna_minimize.js');
    await scriptFile.writeAsString(
      kwinMinimizeRestoreScript
          .replaceAll('%windowId%', windowId)
          .replaceAll('%minimize%', 'true'),
    );

    try {
      await kwin.loadScript(scriptFile.path, 'nyrna_minimize');
    } catch (e, st) {
      log.e('Failed to load minimize script', error: e, stackTrace: st);
      return false;
    }

    // callreconfigure() is fire-and-forget (noReplyExpected), so KWin executes
    // the script asynchronously after loadScript() returns. Wait briefly before
    // deleting the temp file to ensure KWin has had time to read it.
    await Future.delayed(const Duration(milliseconds: 500));
    await scriptFile.delete();
    return true;
  }

  @override
  Future<bool> restoreWindow(String windowId) async {
    log.i('Restoring window with id $windowId');

    switch (sessionType.displayProtocol) {
      case DisplayProtocol.wayland:
        switch (sessionType.environment) {
          case DesktopEnvironment.kde:
            return await _restoreWindowWaylandKDE(windowId);
          default:
            // For non-KDE Wayland (e.g. GNOME), window listing falls back to
            // X11/wmctrl, so window IDs are X11 integers — use xdotool.
            return await _restoreWindowX11(windowId);
        }
      case DisplayProtocol.x11:
        return await _restoreWindowX11(windowId);
      default:
        return Future.error('Unknown session type: $sessionType.displayProtocol');
    }
  }

  Future<bool> _restoreWindowX11(String windowId) async {
    final result = await _run(
      'xdotool',
      ['windowactivate', windowId],
    );
    return (result.stderr == '') ? true : false;
  }

  /// Returns true if [windowId] is a valid UUID or hex window ID.
  ///
  /// This guards against JS injection into KWin scripts from a malformed ID.
  bool _isValidWindowId(String windowId) {
    return RegExp(r'^\{?[0-9a-fA-F-]+\}?$').hasMatch(windowId);
  }

  Future<bool> _restoreWindowWaylandKDE(String windowId) async {
    if (!_isValidWindowId(windowId)) {
      log.e('Invalid windowId for restore: $windowId');
      return false;
    }

    // Create a javascript file in a host-visible directory so KWin can load it.
    final scriptDir = _tempScriptDir.isNotEmpty
        ? _tempScriptDir
        : io.Directory.systemTemp.path;
    final scriptFile = io.File('$scriptDir/nyrna_restore.js');
    await scriptFile.writeAsString(
      kwinMinimizeRestoreScript
          .replaceAll('%windowId%', windowId)
          .replaceAll('%minimize%', 'false'),
    );

    try {
      await kwin.loadScript(scriptFile.path, 'nyrna_restore');
    } catch (e, st) {
      log.e('Failed to load restore script', error: e, stackTrace: st);
      return false;
    }

    // callreconfigure() is fire-and-forget (noReplyExpected), so KWin executes
    // the script asynchronously after loadScript() returns. Wait briefly before
    // deleting the temp file to ensure KWin has had time to read it.
    await Future.delayed(const Duration(milliseconds: 500));
    await scriptFile.delete();
    return true;
  }

  @override
  Future<void> dispose() async {
    await _scriptOutputSubscription?.cancel();
    await kwin.unloadScript(_kdeWaylandScriptName);
    await kwin.unloadScript(ActiveWindowWayland.kdeScriptName);
    await kwin.unloadScript('nyrna_minimize');
    await kwin.unloadScript('nyrna_restore');
    await kwin.dispose();
    await nyrnaDbus.dispose();
    await ActiveWindowWayland.dispose();
  }
}
