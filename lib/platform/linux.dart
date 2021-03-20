import 'dart:io';

import 'package:nyrna/platform/native_platform.dart';
import 'package:nyrna/window/window.dart';

class Linux implements NativePlatform {
  int _desktop;

  // Active virtual desktop as reported by wmctrl.
  @override
  Future<int> get currentDesktop async {
    int desktop;
    var result = await Process.run('wmctrl', ['-d']);
    var lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      if (line.contains('*')) {
        desktop = int.tryParse(line[0]);
      }
    });
    _desktop = desktop;
    return desktop;
  }

  // Gets all open windows from wmctrl.
  @override
  Future<Map<String, Window>> get windows async {
    _desktop = await currentDesktop;
    final windows = <String, Window>{};
    var result = await Process.run('bash', ['-c', 'wmctrl -lp']);
    // Each line from wmctrl will be something like so:
    // 0x03600041  1 1459   SHODAN Inbox - Unified Folders - Mozilla Thunderbird
    // windowId, desktopId, pid, user, window title
    var lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      var parts = line.split(' ');
      parts.removeWhere((part) => part == ''); // Happens with multiple spaces.
      if (parts.length > 1) {
        // Which virtual desktop this window is on.
        var windowDesktop = int.tryParse(parts[1]);
        if (windowDesktop == _desktop) {
          var pid = int.tryParse(parts[2]);
          var id = int.tryParse(parts[0]);
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

  @override
  Future<int> get activeWindowPid async {
    var result =
        await Process.run('xdotool', ['getactivewindow', 'getwindowpid']);
    var _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  @override
  Future<int> get activeWindowId async {
    var result = await Process.run('xdotool', ['getactivewindow']);
    var _windowId = int.tryParse(result.stdout.toString().trim());
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
