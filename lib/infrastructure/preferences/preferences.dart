import 'package:shared_preferences/shared_preferences.dart';

/// Manages settings & preferences.
class Preferences {
  // Settings is a singleton.
  Preferences._privateConstructor();
  static final Preferences instance = Preferences._privateConstructor();

  /// Instance of SharedPreferences for getting and setting preferences.
  SharedPreferences? _prefs;

  /// Initialize should only need to be called once, in main().
  Future<void> initialize() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setBool({required String key, required bool value}) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  Future<void> setInt({required String key, required int value}) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) => _prefs?.getInt(key);

  Future<void> setString({required String key, required String value}) async {
    assert(key != '');
    assert(value != '');
    await _prefs?.setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);

  /// Remove a value from stored preferences.
  Future<bool> remove(String key) async => await _prefs!.remove(key);
}
