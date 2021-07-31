import 'dart:io' as io;

import 'package:nyrna/domain/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/native_platform/src/linux/linux_process.dart';

import '../native_platform.dart';

/// Interact with the native Linux operating system.
class Linux implements NativePlatform {
  int? _desktop;

  // Active virtual desktop as reported by wmctrl.
  @override
  Future<int> get currentDesktop async {
    final result = await io.Process.run('wmctrl', ['-d']);
    final lines = result.stdout.toString().split('\n');
    lines.forEach((line) {
      if (line.contains('*')) _desktop = int.tryParse(line[0]);
    });
    return _desktop ?? 0;
  }

  // Gets all open windows as reported by wmctrl.
  @override
  Future<List<Window>> windows() async {
    await currentDesktop;
    final windows = <Window>[];
    final result = await io.Process.run('bash', ['-c', 'wmctrl -lp']);
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
          windows.add(Window(
            id: id,
            title: parts.sublist(4).join(' '),
          ));
        }
      }
    });
    return windows;
  }

  // Returns the PID of the active window as reported by xdotool.
  @override
  Future<int> get activeWindowPid async {
    final result = await io.Process.run(
      'xdotool',
      ['getactivewindow', 'getwindowpid'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  // Returns the unique hex ID of the active window as reported by xdotool.
  @override
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
      ['$windowId', 'getwindowpid'],
    );
    final _pid = int.tryParse(result.stdout.toString().trim());
    return _pid ?? 0;
  }

  @override
  Future<Process> windowProcess(int windowId) async {
    final pid = await windowPid(windowId);
    final linuxProcess = LinuxProcess(pid);
    final executable = await linuxProcess.executable;
    final status = await linuxProcess.status;
    final process = Process(executable: executable, pid: pid, status: status);
    return process;
  }

  @override
  Future<bool> minimizeWindow(int windowId) async {
    final result = await io.Process.run(
      'xdotool',
      ['windowminimize', '$windowId', '--sync'],
    );
    return true;
    // TODO: Check for possible stderr for meaningful return value.
    // result.stderr
  }

  @override
  Future<bool> restoreWindow(int windowId) async {
    final result = await io.Process.run(
      'xdotool',
      ['windowactivate', '$windowId', '--sync'],
    );
    return true;
    // TODO: Check for possible stderr for meaningful return value.
    // result.stderr
  }
}
