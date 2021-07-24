import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyrna/application/theme/enums/app_theme.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages settings & preferences.
class Preferences {
  // Settings is a singleton.
  Preferences._privateConstructor();
  static final Preferences instance = Preferences._privateConstructor();

  static final _log = Logger('Settings');

  /// Instance of SharedPreferences for getting and setting preferences.
  SharedPreferences? prefs;

  /// Initialize should only need to be called once, in main().
  Future<void> initialize() async {
    if (prefs != null) return;
    prefs = await SharedPreferences.getInstance();
    if (!Config.toggle) await _readVersion(); // Not needed for toggle func.
  }

  /// Read Nyrna's version info from the `VERSION` file.
  Future<void> _readVersion() async {
    File? file;
    try {
      file = File('VERSION');
    } catch (e) {
      _log.info('No VERSION file found in current directory.\n'
          '$e');
    }
    if (Platform.isLinux && file == null) {
      // This is necessary for AppImage, because it runs in a temp folder.
      // Gets the path to the running executable, then read the VERSION
      // file that is in that directory.
      final nyrnaPath = Platform.resolvedExecutable;
      final splitPath = nyrnaPath.split('');
      final lastSeperator = splitPath.lastIndexOf('/');
      final path = splitPath.sublist(0, lastSeperator).join();
      file = File('$path/VERSION');
    } else {
      file = File('VERSION');
    }
    final exists = await file.exists();
    if (exists) {
      final version = await file.readAsString();
      Globals.version = version.trim();
    } else {
      Globals.version = 'Unknown';
    }
  }

  /// Whether or not to automatically refresh the list of open windows.
  bool get autoRefresh {
    bool defaultValue;
    defaultValue = (Platform.isWindows) ? false : true;
    return prefs!.getBool('autoRefresh') ?? defaultValue;
  }

  Future<void> setAutoRefresh(bool shouldRefresh) async {
    await prefs?.setBool('autoRefresh', shouldRefresh);
  }

  /// How often to automatically refresh the list of open windows, in seconds.
  int get refreshInterval => prefs!.getInt('refreshInterval') ?? 5;

  set refreshInterval(int interval) {
    if (interval > 0) {
      prefs!.setInt('refreshInterval', interval);
    }
  }

  /// The PID of the process Nyrna suspended via [ActiveWindow.toggle()].
  ///
  /// Returns 0 if Nyrna hasn't suspended anything in this fashion.
  int get savedProcess => prefs!.getInt('savedProcess') ?? 0;

  Future<void> setSavedProcess(int pid) async {
    await prefs!.setInt('savedProcess', pid);
  }

  /// The unique hex ID of the window suspended via [ActiveWindow.toggle()].
  int? get savedWindowId => prefs!.getInt('savedWindowId');

  Future<void> setSavedWindowId(int id) async {
    await prefs!.setInt('savedWindowId', id);
  }

  /// If user has ignored an update that version number is saved here.
  String? get ignoredUpdate => prefs!.getString('ignoredUpdate');

  /// Check for `PORTABLE` file in the Nyrna directory, which should only be
  /// present for the portable build on Linux.
  Future<bool> get isPortable async {
    final file = File('PORTABLE');
    return await file.exists();
  }

  static const int _defaultIconColor = 2617291775;

  int get iconColor => prefs!.getInt('iconColor') ?? _defaultIconColor;

  Future<void> setIconColor(int color) async {
    await prefs!.setInt('iconColor', color);
  }

  AppTheme get appTheme {
    final savedTheme = prefs?.getString('appTheme');
    switch (savedTheme) {
      case null:
        return AppTheme.dark;
      case 'AppTheme.light':
        return AppTheme.light;
      case 'AppTheme.dark':
        return AppTheme.dark;
      case 'AppTheme.pitchBlack':
        return AppTheme.pitchBlack;
      default:
        return AppTheme.dark;
    }
  }

  set appTheme(AppTheme appTheme) {
    prefs?.setString('appTheme', appTheme.toString());
  }
}
