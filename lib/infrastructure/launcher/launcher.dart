import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart' as pp;

import 'src/hotkey.dart';

/// Manage launcher entry.
///
/// Enables system integration for Nyrna to provide a shortcut in the user's
/// launcher / start menu with Nyrna's associated icon.
///
/// Currently only for the portable version on Linux.
class Launcher {
  static Hotkey get hotkey => Hotkey();

  /// Add a launcher entry for Nyrna with icon.
  static Future<void> add() async {
    await _addLauncher();
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

  static String? _executablePath;

  /// Absolute path to Nyrna's executable.
  static String get executablePath {
    if (_executablePath != null) return _executablePath!;
    _executablePath = Platform.resolvedExecutable;
    return _executablePath!;
  }

  static String? _nyrnaDir;

  /// Absolute path to Nyrna's install directory.
  static String get directory {
    if (_nyrnaDir != null) return _nyrnaDir!;
    final nyrnaPath = executablePath.substring(0, (executablePath.length - 5));
    _nyrnaDir = nyrnaPath;
    return nyrnaPath;
  }

  static String? _iconPath;

  /// Absolute path to Nyrna's bundled icon asset.
  static String? get iconPath {
    if (_iconPath != null) return _iconPath;
    final _ending = (Platform.isLinux) ? 'png' : 'ico';
    _iconPath = '${directory}data/flutter_assets/assets/icons/nyrna.$_ending';
    return _iconPath;
  }
}

/// Manage launcher entry on Linux.
class _LinuxLauncher {
  static Future<void> add() async {
    await _addIcon();
    await _addDesktopFile();
  }

  static final _log = Logger('_LinuxLauncher');

  /// Install Nyrna's icon according to the XDG specification.
  ///
  /// (Likely ~/.local/share/icons/hicolor/256x256/apps/nyrna.png)
  ///
  /// https://portland.freedesktop.org/doc/xdg-icon-resource.html
  static Future<void> _addIcon() async {
    try {
      await Process.run(
        'xdg-icon-resource',
        ['install', '--novendor', '--size', '256', '${Launcher.iconPath}'],
      );
    } catch (err) {
      _log.severe('Issue adding icon: \n'
          '$err');
    }
  }

  /// Install Nyrna's .desktop file according to the XDG specification.
  ///
  /// (Likely ~/.local/share/applications/nyrna.desktop)
  ///
  /// https://portland.freedesktop.org/xdg-utils-1.1.0-rc1/scripts/html/xdg-desktop-menu.html
  static Future<void> _addDesktopFile() async {
    // Write .desktop file to disk in the temp directory.

    final tempDir = await pp.getTemporaryDirectory();
    final desktopFile = File('$tempDir/nyrna.desktop');
    await desktopFile.writeAsString(_desktopFileContent);
    // Install to xdg location.
    try {
      await Process.run(
        'xdg-desktop-menu',
        ['install', '--novendor', '${desktopFile.path}'],
      );
    } catch (err) {
      _log.severe('Issue adding desktop file: \n'
          '$err');
    }
  }
}

final String _desktopFileContent = '''
[Desktop Entry]
Type=Application
Name=Nyrna
Comment=Suspend games & applications
Exec=${Launcher.executablePath}
Icon=nyrna
Terminal=false
StartupNotify=false
Categories=Utility;
''';
