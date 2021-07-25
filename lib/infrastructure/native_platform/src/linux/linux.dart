import 'dart:io';

import 'package:nyrna/window/window.dart';

import '../native_platform.dart';

/// Interact with the native Linux operating system.
class Linux implements NativePlatform {
  int? _desktop;

  // Active virtual desktop as reported by wmctrl.
  @override
  Future<int> get currentDesktop async {
    final result = await Process.run('wmctrl', ['-d']);
    final lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      if (line.contains('*')) _desktop = int.tryParse(line[0]);
    });
    return _desktop ?? 0;
  }

  // Gets all open windows as reported by wmctrl.
  @override
  Future<Map<String, Window>> get windows async {
    await currentDesktop;
    final windows = <String, Window>{};
    final result = await Process.run('bash', ['-c', 'wmctrl -lp']);
    // Each line from wmctrl will be something like:
    // 0x03600041  1 1459   SHODAN Inbox - Unified Folders - Mozilla Thunderbird
    // windowId, desktopId, pid, user, window title
    final lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      final parts = line.split(' ');
      parts.removeWhere((part) => part == ''); // Happens with multiple spaces.
      if (parts.length > 1) {
        // Which virtual desktop this window is on.
        final windowDesktop = int.tryParse(parts[1]);
        if (windowDesktop == _desktop) {
          final pid = int.tryParse(parts[2]);
          final id = int.tryParse(parts[0]);
          if ((pid == null) || (id == null)) return;
          windows[pid.toString()] = Window(
            title: parts.sublist(4).join(' '),
            pid: pid,
            id: id,
          );
        }
      }
    });
    return windows;
  }

  // Returns the PID of the active window as reported by xdotool.
  @override
  Future<int> get activeWindowPid async {
    final result = await Process.run(
      'xdotool',
      ['getactivewindow', 'getwindowpid'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  // Returns the unique hex ID of the active window as reported by xdotool.
  @override
  Future<int> get activeWindowId async {
    final result = await Process.run('xdotool', ['getactivewindow']);
    final _windowId = int.tryParse(result.stdout.toString().trim());
    return _windowId ?? 0;
  }

  // Verify wmctrl and xdotool are present on the system.
  @override
  Future<bool> checkDependencies() async {
    try {
      await Process.run('wmctrl', ['-d']);
    } catch (err) {
      return false;
    }
    try {
      await Process.run('xdotool', ['getactivewindow']);
    } catch (err) {
      return false;
    }
    return true;
  }
}
