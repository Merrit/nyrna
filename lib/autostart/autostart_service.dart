import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

import '../logs/logging_manager.dart';
import '../native_platform/src/linux/flatpak.dart';

/// Service to enable/disable autostart on desktop platforms.
class AutostartService {
  /// Disables autostart on login.
  Future<void> disable() async {
    assert(defaultTargetPlatform.isDesktop);

    if (runningInFlatpak) {
      await _setForFlatpak(false);
    } else if (defaultTargetPlatform.isWindows && await _isRunningInMsix()) {
      await _disableForMSIX();
    } else {
      await _disableForDesktop();
    }
  }

  /// Enables autostart on login.
  Future<void> enable() async {
    assert(defaultTargetPlatform.isDesktop);

    if (runningInFlatpak) {
      await _setForFlatpak(true);
    } else if (defaultTargetPlatform.isWindows && await _isRunningInMsix()) {
      await _enableForMSIX();
    } else {
      await _enableForDesktop();
    }
  }

  Future<void> _disableForDesktop() async {
    await _setupLaunchAtStartup();
    await launchAtStartup.disable();
  }

  /// Disable autostart for MSIX apps.
  Future<void> _disableForMSIX() async {
    log.i('Disabling autostart for MSIX app.');

    const String script = '''
    Remove-Item -Path '%userprofile%\\Start Menu\\Programs\\Startup\\Nyrna.lnk'
  ''';

    await Process.run(
      'powershell',
      ['-Command', script],
      runInShell: true,
    );

    log.i('Removed shortcut from Startup folder.');
  }

  Future<void> _enableForDesktop() async {
    await _setupLaunchAtStartup();
    await launchAtStartup.enable();
  }

  /// If the app is an msix from the Microsoft Store, we can't use the
  /// launch_at_startup package until a bug is fixed.
  ///
  /// See: https://github.com/leanflutter/launch_at_startup/issues/7
  ///
  /// This workaround manually creates a shortcut in the Startup folder.
  Future<void> _enableForMSIX() async {
    log.i('Setting up autostart for MSIX app.');

    final String resolvedExecutable = Platform.resolvedExecutable;
    final String currentDirectory = Directory.current.path;
    final String appExeDir = currentDirectory;

    final String script = '''
    \$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\\Start Menu\\Programs\\Startup\\Nyrna.lnk');
    \$s.TargetPath='$resolvedExecutable';
    \$s.Arguments='';
    \$s.IconLocation='%userprofile%\\Start Menu\\Programs\\Nyrna.lnk';
    \$s.WorkingDirectory='$appExeDir';
    \$s.WindowStyle=7;
    \$s.Save()
  ''';

    await Process.run(
      'powershell',
      ['-Command', script],
      runInShell: true,
    );

    log.i('Created shortcut in Startup folder.');
  }

  /// Returns whether the app is running in an msix package from the Microsoft
  /// Store.
  Future<bool> _isRunningInMsix() async {
    final String resolvedExecutable = Platform.resolvedExecutable;
    // The path to the executable will be something like:
    // C:\Program Files\WindowsApps\33694MerrittCodes.Nyrna_2.14.0.0_x64__9kjrd3yy77d9e\nyrna.exe
    // We want to check if the path contains "WindowsApps" and "33694MerrittCodes.Nyrna".
    const kMicrosoftStorePackageName = '33694MerrittCodes.Nyrna';
    final bool isMsix = resolvedExecutable.contains('WindowsApps') &&
        resolvedExecutable.contains(kMicrosoftStorePackageName);
    log.i('Running in MSIX: $isMsix');
    return isMsix;
  }

  Future<void> _setForFlatpak(bool enable) async {
    final client = XdgDesktopPortalClient();

    await client.background.requestBackground(
      reason: 'Autostarting Adventure List',
      autostart: enable,
      commandLine: ['flatpak', 'run', 'codes.merritt.adventurelist'],
    ).first;

    await client.close();
  }

  Future<void> _setupLaunchAtStartup() async {
    final packageInfo = await PackageInfo.fromPlatform();

    log.w(
      'packageName: ${packageInfo.packageName}\n'
      'resolvedExecutable: ${Platform.resolvedExecutable}',
    );

    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
  }
}
