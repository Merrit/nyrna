import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/window/window.dart';

/// Represents Nyrna, its state, and interactions.
class Nyrna extends ChangeNotifier {
  Nyrna() {
    setRefresh();
  }

  Timer? _timer;

  /// The time which auto-refreshes the list of open windows.
  void setRefresh() {
    fetchData();
    if (_timer != null) _timer!.cancel();
    if (_settings.autoRefresh) {
      _timer = Timer.periodic(
        Duration(seconds: _settings.refreshInterval),
        (timer) => fetchData(),
      );
    }
  }

  final _nativePlatform = NativePlatform();

  final _settings = Preferences.instance;

  int? _currentDesktop;

  /// Returns the index of the currently active virtual desktop.
  ///
  /// The left-most / first desktop starts at index 0.
  int? get currentDesktop => _currentDesktop;

  /// Check which virtual desktop is active.
  Future<void> fetchDesktop() async {
    _currentDesktop = await _nativePlatform.currentDesktop;
    notifyListeners();
  }

  final Map<String, Window> _windows = {};

  /// [Map] where keys are [pid] and values are [Window] objects.
  Map<String, Window> get windows => _windows;

  /// Check for which windows are open.
  Future<void> fetchWindows() async {
    final newWindows = await _nativePlatform.windows;
    // Remove if window no longer present, or title has changed.
    _windows.removeWhere((pid, window) {
      if (!newWindows.containsKey(pid) || // Window no longer present.
          (newWindows[pid]!.title != window.title)) // Window title changed.
      {
        return true;
      } else {
        return false;
      }
    });
    // Filter out Nyrna's own window / process.
    newWindows.removeWhere((pid, window) => pid == io.pid.toString());
    // Add new windows (and those whose title changed).
    newWindows.forEach((pid, window) {
      if (!_windows.containsKey(pid)) _windows[pid] = window;
    });
    notifyListeners();
  }

  /// Fetch fresh data.
  void fetchData() {
    fetchDesktop();
    fetchWindows();
    notifyListeners();
  }

  static String? _executablePath;

  /// Absolute path to Nyrna's executable.
  static String get executablePath {
    if (_executablePath != null) return _executablePath!;
    _executablePath = io.Platform.resolvedExecutable;
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
    final _ending = (io.Platform.isLinux) ? 'png' : 'ico';
    _iconPath = '${directory}data/flutter_assets/assets/icons/nyrna.$_ending';
    return _iconPath;
  }

  /// Instantiate the Nyrna class without a timer.
  ///
  /// Used by [Loading] when checking dependencies at startup.
  Nyrna.loading();

  /// Verify Nyrna's dependencies are available on the system.
  Future<bool> checkDependencies() async {
    return await _nativePlatform.checkDependencies();
  }
}
