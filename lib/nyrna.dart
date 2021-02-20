import 'dart:async';
import 'dart:io' as DartIO;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nyrna/linux/linux.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window.dart';

class Nyrna extends ChangeNotifier {
  Nyrna() {
    setRefresh();
  }

  Timer _timer;

  void setRefresh() {
    fetchData();
    if (_timer != null) _timer.cancel();
    if (settings.autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: settings.refreshInterval),
        (timer) => fetchData(),
      );
    }
  }

  int _currentDesktop;

  /// Returns the index of the currently active virtual desktop.
  ///
  /// The left-most / first desktop starts at 0.
  ///
  // ignore: missing_return
  int get currentDesktop {
    return _currentDesktop;
  }

  void fetchDesktop() {
    if (DartIO.Platform.isLinux) _currentDesktop = Linux.currentDesktop;
    if (DartIO.Platform.isWindows) return null;
    if (DartIO.Platform.isMacOS) return null;
    notifyListeners();
  }

  Map<String, Window> _windows = {};

  /// Map where keys are [pid] and values are [Window] objects.
  Map<String, Window> get windows => _windows;

  Future<void> fetchWindows() async {
    Map<String, Window> newWindows;
    if (DartIO.Platform.isLinux) newWindows = await Linux.windows;
    if (DartIO.Platform.isWindows) return null;
    if (DartIO.Platform.isMacOS) return null;
    // Remove if window no longer present.
    _windows.removeWhere((pid, _) => !newWindows.containsKey(pid));
    // Filter out own window.
    newWindows.removeWhere((pid, window) => window.title == 'Nyrna');
    // Add new windows.
    newWindows.forEach((pid, window) {
      if (!_windows.containsKey(pid)) _windows[pid] = window;
    });
    notifyListeners();
  }

  void fetchData() {
    fetchDesktop();
    fetchWindows();
    notifyListeners();
  }

  /// Hide the Nyrna window.
  ///
  /// Necessary when using the toggle active window feature,
  /// until Flutter has a way to run without GUI.
  static Future<void> hide() async {
    switch (DartIO.Platform.operatingSystem) {
      case 'linux':
        await _hideLinux();
        break;
      default:
        break;
    }
    return null;
  }

  static Future<void> _hideLinux() async {
    await DartIO.Process.run(
      'xdotool',
      ['getactivewindow', 'windowunmap', '--sync'],
    );
    return null;
  }

  static String _executablePath;

  /// Absolute path to Nyrna's executable.
  static String get executablePath {
    if (_executablePath != null) return _executablePath;
    _executablePath = DartIO.Platform.resolvedExecutable;
    return _executablePath;
  }

  static String _nyrnaDir;

  /// Absolute path to Nyrna's install directory.
  static String get directory {
    if (_nyrnaDir != null) return _nyrnaDir;
    var nyrnaPath = executablePath.substring(0, (executablePath.length - 5));
    _nyrnaDir = nyrnaPath;
    return nyrnaPath;
  }

  static String _iconPath;

  /// Absolute path to Nyrna's bundled icon asset.
  static String get iconPath {
    if (_iconPath != null) return _iconPath;
    var _ending = (DartIO.Platform.isLinux) ? 'png' : 'ico';
    _iconPath = '${directory}data/flutter_assets/assets/icons/nyrna.$_ending';
    return _iconPath;
  }

  static String _tempDir;

  /// Absolute path to the operating system's temp directory.
  static Future<String> get tempDirectory async {
    if (_tempDir != null) return _tempDir;
    final directory = await getTemporaryDirectory();
    _tempDir = directory.path;
    return _tempDir;
  }

  /// Verify Nyrna's dependencies are available on the system.
  static Future<bool> checkDependencies() async {
    bool dependenciesPresent = false;
    switch (DartIO.Platform.operatingSystem) {
      case 'linux':
        dependenciesPresent = await Linux.checkDependencies();
        break;
      default:
        break;
    }
    return dependenciesPresent;
  }
}
