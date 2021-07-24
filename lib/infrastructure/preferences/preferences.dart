import 'dart:io';

import 'package:nyrna/application/theme/enums/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages settings & preferences.
class Preferences {
  // Settings is a singleton.
  Preferences._privateConstructor();
  static final Preferences instance = Preferences._privateConstructor();

  /// Instance of SharedPreferences for getting and setting preferences.
  SharedPreferences? prefs;

  /// Initialize should only need to be called once, in main().
  Future<void> initialize() async {
    if (prefs != null) return;
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString({required String key, required String value}) async {
    assert(key != '');
    assert(value != '');
    await prefs?.setString(key, value);
  }

  String? getString(String key) => prefs?.getString(key);

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
