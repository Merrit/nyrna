import 'dart:io';

import 'package:nyrna/window.dart';

class Linux {
  static int _desktop;

  /// Returns the index of the currently active
  /// virtual desktop as reported by wmctrl.
  static int get currentDesktop {
    int desktop;
    var result = Process.runSync('wmctrl', ['-d']);
    var lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      if (line.contains('*')) {
        desktop = int.tryParse(line[0]);
      }
    });
    _desktop = desktop;
    return desktop;
  }

  /// Returns a list of [Window] objects based on the reported
  /// open application windows from wmctrl.
  ///
  /// Expects [currentDesktop] to have been called first for the desktop number.
  static Future<Map<String, Window>> get windows async {
    _desktop = currentDesktop;
    Map<String, Window> windows = {};
    var result = await Process.run('bash', ['-c', 'wmctrl -lp']);
    // Each line from wmctrl will be something like so:
    // 0x03600041  1 1459   SHODAN Inbox - Unified Folders - Mozilla Thunderbird
    // windowId, desktopId, pid, user, window title
    var lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      var parts = line.split(' ');
      parts.removeWhere((part) => part == ""); // Happens with multiple spaces.
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

  static int get activeWindowPid {
    var result =
        Process.runSync('xdotool', ['getactivewindow', 'getwindowpid']);
    var _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  /// Unique hex id for the active window.
  static int get activeWindowId {
    var result = Process.runSync('xdotool', ['getactivewindow']);
    var _windowId = int.tryParse(result.stdout.toString().trim());
    return _windowId ?? 0;
  }
}
