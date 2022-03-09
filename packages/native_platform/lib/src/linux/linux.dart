import 'dart:io' as io;

import '../active_window.dart';
import '../native_platform.dart';
import '../window.dart';
import 'linux_process.dart';

/// System-level or non-app executables. Nyrna shouldn't show these.
const List<String> _filteredWindows = [
  'nyrna',
];

/// Interact with the native Linux operating system.
class Linux implements NativePlatform {
  int? _desktop;

  // Active virtual desktop as reported by wmctrl.
  @override
  Future<int> currentDesktop() async {
    final result = await io.Process.run('wmctrl', ['-d']);
    final lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      if (line.contains('*')) _desktop = int.tryParse(line[0]);
    });
    return _desktop ?? 0;
  }

  // Gets all open windows as reported by wmctrl.
  @override
  Future<List<Window>> windows({required bool showHidden}) async {
    await currentDesktop();
    final windows = <Window>[];
    final result = await io.Process.run('bash', ['-c', 'wmctrl -lp']);
    // Each line from wmctrl will be something like:
    // 0x03600041  1 1459   SHODAN Inbox - Unified Folders - Mozilla Thunderbird
    // windowId, desktopId, pid, user, window title
    final lines = result.stdout.toString().split('\n');
    await Future.forEach(lines, (String line) async {
      final parts = line.split(' ');
      parts.removeWhere((part) => part == ''); // Happens with multiple spaces.
      if (parts.length > 1) {
        // Which virtual desktop this window is on.
        final windowDesktop = int.tryParse(parts[1]);
        final windowOnCurrentDesktop = (windowDesktop == _desktop);
        if (windowOnCurrentDesktop || showHidden) {
          final pid = int.tryParse(parts[2]);
          final id = int.tryParse(parts[0]);
          if ((pid == null) || (id == null)) return;
          final executable = await _getExecutableName(pid);
          if (_filteredWindows.contains(executable)) return;
          final linuxProcess = LinuxProcess(executable: executable, pid: pid);
          windows.add(
            Window(
              id: id,
              process: linuxProcess,
              title: parts.sublist(4).join(' '),
            ),
          );
        }
      }
    });
    return windows;
  }

  Future<String> _getExecutableName(int pid) async {
    final result = await io.Process.run('readlink', ['/proc/$pid/exe']);
    final executable = result.stdout.toString().split('/').last.trim();
    return executable;
  }

  @override
  Future<ActiveWindow> activeWindow() async {
    final windowId = await activeWindowId;
    if (windowId == 0) throw (Exception('No window id'));
    final pid = await windowPid(windowId);
    if (pid == 0) throw (Exception('No pid'));
    final executable = await _getExecutableName(pid);
    final linuxProcess = LinuxProcess(pid: pid, executable: executable);
    final activeWindow = ActiveWindow(
      NativePlatform(),
      linuxProcess,
      id: windowId,
      pid: pid,
    );
    return activeWindow;
  }

  // Returns the PID of the active window as reported by xdotool.
  Future<int> get activeWindowPid async {
    final result = await io.Process.run(
      'xdotool',
      ['getactivewindow', 'getwindowpid'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  // Returns the unique hex ID of the active window as reported by xdotool.
  Future<int> get activeWindowId async {
    final result = await io.Process.run('xdotool', ['getactivewindow']);
    final _windowId = int.tryParse(result.stdout.toString().trim());
    return _windowId ?? 0;
  }

  // Verify wmctrl and xdotool are present on the system.
  @override
  Future<bool> checkDependencies() async {
    try {
      await io.Process.run('wmctrl', ['-d']);
    } catch (err) {
      return false;
    }
    try {
      await io.Process.run('xdotool', ['getactivewindow']);
    } catch (err) {
      return false;
    }
    return true;
  }

  @override
  Future<int> windowPid(int windowId) async {
    final result = await io.Process.run(
      'xdotool',
      ['getwindowpid', '$windowId'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  @override
  Future<bool> minimizeWindow(int windowId) async {
    final result = await io.Process.run(
      'xdotool',
      ['windowminimize', '$windowId'],
    );
    return (result.stderr == '') ? true : false;
  }

  @override
  Future<bool> restoreWindow(int windowId) async {
    final result = await io.Process.run(
      'xdotool',
      ['windowactivate', '$windowId'],
    );
    return (result.stderr == '') ? true : false;
  }
}
