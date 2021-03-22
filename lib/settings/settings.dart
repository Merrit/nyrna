import 'dart:io';

import 'package:nyrna/config.dart';
import 'package:nyrna/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manage all the app settings.
class Settings {
  // Settings is a singleton.
  Settings._privateConstructor();
  static final Settings instance = Settings._privateConstructor();

  SharedPreferences prefs;

  Future<void> initialize() async {
    if (prefs != null) return;
    prefs = await SharedPreferences.getInstance();
    if (!Config.toggle) await _readVersion();
  }

  Future<void> _readVersion() async {
    final file = File('VERSION');
    final version = await file.readAsString();
    Globals.version = version.trim();
  }

  bool get autoRefresh => prefs.getBool('autoRefresh') ?? true;

  set autoRefresh(bool shouldRefresh) {
    prefs.setBool('autoRefresh', shouldRefresh);
  }

  int get refreshInterval => prefs.getInt('refreshInterval') ?? 5;

  set refreshInterval(int interval) {
    if (interval > 0) {
      prefs.setInt('refreshInterval', interval);
    }
  }

  int get savedProcess => prefs.getInt('savedProcess') ?? 0;

  Future<void> setSavedProcess(int pid) async {
    await prefs.setInt('savedProcess', pid);
  }

  int get savedWindowId => prefs.getInt('savedWindowId');

  Future<void> setSavedWindowId(int id) async {
    await prefs.setInt('savedWindowId', id);
  }

  /// If user has ignored an update that version number is saved here.
  String get ignoredUpdate => prefs.getString('ignoredUpdate');

  /// Check for `PORTABLE` file in the Nyrna directory, which should only be
  /// present for the portable build on Linux.
  Future<bool> isPortable() async {
    final file = File('PORTABLE');
    return await file.exists();
  }
}
