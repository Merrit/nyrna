import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/globals.dart';
import 'package:nyrna/nyrna.dart';

/// Manage launcher entry.
///
/// Enables system integration for Nyrna to provide a shortcut in the user's
/// launcher / start menu with Nyrna's associated icon.
class Launcher {
  /// Add a launcher entry for Nyrna with icon.
  static Future<void> add(BuildContext context) async {
    await _addLauncher();
    Navigator.pop(context);
  }

  static Future<void> _addLauncher() async {
    switch (Platform.operatingSystem) {
      case 'linux':
        await _LinuxLauncher.add();
        break;
      case 'windows':
        break;
      default:
        break;
    }
  }
}

/// Manage launcher entry on Linux.
class _LinuxLauncher {
  static Future<void> add() async {
    await _addIcon();
    await _addDesktopFile();
  }

  /// Install Nyrna's icon according to the XDG specification.
  ///
  /// (Likely ~/.local/share/icons/hicolor/256x256/apps/nyrna.png)
  ///
  /// https://portland.freedesktop.org/doc/xdg-icon-resource.html
  static Future<void> _addIcon() async {
    var result = await Process.run(
      'xdg-icon-resource',
      ['install', '--novendor', '--size', '256', '${Nyrna.iconPath}'],
    );
  }

  /// Install Nyrna's .desktop file according to the XDG specification.
  ///
  /// (Likely ~/.local/share/applications/nyrna.desktop)
  ///
  /// https://portland.freedesktop.org/xdg-utils-1.1.0-rc1/scripts/html/xdg-desktop-menu.html
  static Future<void> _addDesktopFile() async {
    // Write .desktop file to disk in the temp directory.
    final tempDir = await Nyrna.tempDirectory;
    final desktopFile = File('$tempDir/nyrna.desktop');
    await desktopFile.writeAsString(_desktopFileContent);
    // Install to xdg location.
    var result = await Process.run(
      'xdg-desktop-menu',
      ['install', '--novendor', '${desktopFile.path}'],
    );
  }
}

final String _desktopFileContent = '''
[Desktop Entry]
Version=${Globals.version}
Type=Application
Name=Nyrna
Comment=Simple program to suspend games & applications
Exec=${Nyrna.executablePath}
Icon=nyrna
Terminal=false
StartupNotify=false
Categories=Utility;
''';
