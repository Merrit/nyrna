import '../../../logs/logs.dart';
import '../native_platform.dart';
import '../process/models/process.dart';
import '../typedefs.dart';
import '../window.dart';

/// System-level or non-app executables. Nyrna shouldn't show these.
const List<String> _filteredWindows = [
  'nyrna',
];

/// Interact with the native Linux operating system.
class Linux implements NativePlatform {
  final RunFunction _run;

  Linux(this._run);

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
    final windowOnCurrentDesktop = (windowDesktop == _desktop ||
        windowDesktop == _kStickyWindowIdentifier);
    if (!windowOnCurrentDesktop && !showHidden) return null;

    final pid = int.tryParse(parts[2]);
    final id = int.tryParse(parts[0]);
    if ((pid == null) || (id == null)) return null;

    final executable = await _getExecutableName(pid);
    if (_filteredWindows.contains(executable)) return null;

    final process = Process(
      executable: executable,
      pid: pid,
      status: ProcessStatus.unknown,
    );
    final title = parts.sublist(4).join(' ');

    return Window(id: id, process: process, title: title);
  }

  Future<String> _getExecutableName(int pid) async {
    final result = await _run('readlink', ['/proc/$pid/exe']);
    final executable = result.stdout.toString().split('/').last.trim();
    return executable;
  }

  @override
  Future<Window> activeWindow() async {
    final windowId = await _activeWindowId();
    if (windowId == 0) throw (Exception('No window id'));

    final pid = await _activeWindowPid(windowId);
    if (pid == 0) throw (Exception('No pid'));

    final executable = await _getExecutableName(pid);
    final process = Process(
      pid: pid,
      executable: executable,
      status: ProcessStatus.unknown,
    );
    final windowTitle = await _activeWindowTitle();

    return Window(
      id: windowId,
      process: process,
      title: windowTitle,
    );
  }

  // Returns the unique hex ID of the active window as reported by xdotool.
  Future<int> _activeWindowId() async {
    final result = await _run('xdotool', ['getactivewindow']);
    final _windowId = int.tryParse(result.stdout.toString().trim());
    return _windowId ?? 0;
  }

  Future<int> _activeWindowPid(int windowId) async {
    final result = await _run(
      'xdotool',
      ['getwindowpid', '$windowId'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  Future<String> _activeWindowTitle() async {
    final result = await _run(
      'xdotool',
      ['getactivewindow getwindowname'],
    );
    return result.stdout.toString().trim();
  }

  // Verify wmctrl and xdotool are present on the system.
  @override
  Future<bool> checkDependencies() async {
    try {
      await _run('wmctrl', ['-d']);
    } catch (err) {
      return false;
    }
    try {
      await _run('xdotool', ['getactivewindow']);
    } catch (err) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> minimizeWindow(int windowId) async {
    log.v('Minimizing window with id $windowId');
    final result = await _run(
      'xdotool',
      ['windowminimize', '$windowId'],
    );
    return (result.stderr == '') ? true : false;
  }

  @override
  Future<bool> restoreWindow(int windowId) async {
    log.v('Restoring window with id $windowId');
    final result = await _run(
      'xdotool',
      ['windowactivate', '$windowId'],
    );
    return (result.stderr == '') ? true : false;
  }
}
