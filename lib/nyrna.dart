import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:nyrna/platform/native_platform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window/window.dart';

class Nyrna extends ChangeNotifier {
  Nyrna() : _nativePlatform = NativePlatform() {
    setRefresh();
  }

  final _settings = Settings.instance;

  Timer _timer;

  void setRefresh() {
    fetchData();
    if (_timer != null) _timer.cancel();
    if (_settings.autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: _settings.refreshInterval),
        (timer) => fetchData(),
      );
    }
  }

  final NativePlatform _nativePlatform;

  int _currentDesktop;

  /// Returns the index of the currently active virtual desktop.
  ///
  /// The left-most / first desktop starts at 0.
  int get currentDesktop => _currentDesktop;

  Future<void> fetchDesktop() async {
    _currentDesktop = await _nativePlatform.currentDesktop;
    notifyListeners();
  }

  final Map<String, Window> _windows = {};

  /// Map where keys are [pid] and values are [Window] objects.
  Map<String, Window> get windows => _windows;

  Future<void> fetchWindows() async {
    final newWindows = await _nativePlatform.windows;
    // Remove if window no longer present, or title has changed.
    _windows.removeWhere((pid, window) {
      if (!newWindows.containsKey(pid) || // Window no longer present.
          (newWindows[pid].title != window.title)) // Window title changed.
      {
        return true;
      } else {
        return false;
      }
    });
    // Filter out own window.
    newWindows.removeWhere((pid, window) => window.title == 'Nyrna');
    // Add new windows (and those whose title changed).
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

  static String _executablePath;

  /// Absolute path to Nyrna's executable.
  static String get executablePath {
    if (_executablePath != null) return _executablePath;
    _executablePath = io.Platform.resolvedExecutable;
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
    var _ending = (io.Platform.isLinux) ? 'png' : 'ico';
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

  Nyrna.loading() : _nativePlatform = NativePlatform();

  /// Verify Nyrna's dependencies are available on the system.
  Future<bool> checkDependencies() async {
    return await _nativePlatform.checkDependencies();
  }
}
