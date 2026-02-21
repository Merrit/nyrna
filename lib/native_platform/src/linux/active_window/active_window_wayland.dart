import 'dart:convert';
import 'dart:io' as io;

import 'package:helpers/helpers.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../logs/logging_manager.dart';
import '../../../native_platform.dart';
import '../linux.dart';

class ActiveWindowWayland {
  static const String _kdeWaylandScriptName = 'nyrna_get_active_window';

  final String _kdeWaylandScriptPath;
  final Linux _linux;

  ActiveWindowWayland._(this._kdeWaylandScriptPath, this._linux);

  static Future<void> fetch(Linux linux) async {
    final kdeWaylandScriptPath = await _getKdeWaylandScriptPath();
    final service = ActiveWindowWayland._(kdeWaylandScriptPath, linux);

    switch (linux.sessionType.environment) {
      case DesktopEnvironment.kde:
        await service._fetchActiveWindowKde();
      default:
        throw UnimplementedError();
    }
  }

  Future<void> _fetchActiveWindowKde() async {
    log.i('Loading KWin script for active window on KDE Wayland..');
    await _linux.kwin.loadScript(_kdeWaylandScriptPath, _kdeWaylandScriptName);

    _linux.kwin.scriptOutput
        .where((event) => event.contains('Nyrna KDE Wayland:'))
        .listen((event) {
      log.t('KWin script output: $event');
    });

    // Listen for the update from nyrnadbus' activeWindowUpdates
    _linux.nyrnaDbus.activeWindowUpdates.listen((windowString) async {
      log.t('Active window update: $windowString');
      final windowJson = jsonDecode(windowString);
      final pid = int.tryParse(windowJson['pid']);
      if (pid == null) return;
      final executable = await _linux.getExecutableName(pid);

      final process = Process(
        pid: pid,
        executable: executable,
        status: ProcessStatus.unknown,
      );

      final window = Window(
        id: windowJson['internalId'],
        process: process,
        title: windowJson['caption'],
      );

      _linux.activeWindow = window;
      // _linux.updateActiveWindow(window);
    });

    // Short wait to give the script time to run
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<String> _getKdeWaylandScriptPath() async {
    if (io.Platform.environment['FLUTTER_TEST'] == 'true') return '';

    final dataDir = await getApplicationSupportDirectory();
    final tempFile = await assetToTempDir('assets/lib/linux/active_window_kde.js');
    final file =
        io.File('${dataDir.path}${io.Platform.pathSeparator}active_window_kde.js');
    await tempFile.copy(file.path);
    return file.path;
  }
}
