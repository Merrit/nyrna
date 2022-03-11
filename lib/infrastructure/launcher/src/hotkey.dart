import 'dart:io';

import 'package:logging/logging.dart';

/// Hotkey service only exists for Windows, as Linux supports settings
/// custom hotkeys very easily by the end-user with no overhead.
class Hotkey {
  final _log = Logger('Hotkey');

  String _hotkeyExePath() {
    return Directory.current.path + '\\toggle_active_hotkey.exe';
  }

  Future<bool> _createStartupShortcut() async {
    final exePath = _hotkeyExePath();
    final result = await Process.run('powershell', [
      '-NoProfile',
      '\$wShell = New-Object -comObject WScript.Shell',
      ';',
      '\$startupDir = \$env:APPDATA + "\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"',
      ';',
      '\$shortcut = \$wShell.CreateShortcut("\$startupDir\\Nyrna Hotkey.lnk")',
      ';',
      '\$shortcut.TargetPath = "$exePath"',
      ';',
      '\$shortcut.Save()',
    ]);
    if (result.stderr != '') {
      _log.warning('Unable to create startup shortcut: ${result.stderr}');
      return false;
    }
    return true;
  }

  Future<bool> _deleteStartupShortcut() async {
    final result = await Process.run('powershell', [
      '-NoProfile',
      '\$startupDir = \$env:APPDATA + "\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"',
      ';',
      '\$startupDir',
    ]);
    if (result.stderr != '') {
      _log.warning('Unable to find startup dir: ${result.stderr}');
      return false;
    }
    final startupDir = result.stdout.toString().trim();
    final shortcut = File(startupDir + '\\Nyrna Hotkey.lnk');
    final exists = await shortcut.exists();
    if (!exists) return false;
    try {
      await shortcut.delete();
    } catch (e) {
      _log.warning('Unable to delete shortcut: $e');
      return false;
    }
    return true;
  }

  /// Enable or disable the Windows hotkey trigger being
  /// auto-launched at system startup.
  Future<bool> autoStart(bool enabled) async {
    return (enabled)
        ? await _createStartupShortcut()
        : await _deleteStartupShortcut();
  }
}
