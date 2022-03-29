import 'package:shared_preferences/shared_preferences.dart';

/// Persist key value pairs to disk.
class SettingsService {
  /// Instance of SharedPreferences for getting and setting preferences.
  final SharedPreferences _prefs;

  // Settings is a singleton.
  SettingsService._internal(SharedPreferences prefs) : _prefs = prefs;

  static SettingsService? _instance;

  factory SettingsService([SharedPreferences? prefs]) {
    if (_instance == null) {
      assert(prefs != null);
      _instance = SettingsService._internal(prefs!);
    }
    return _instance!;
  }

  Future<void> setBool({required String key, required bool value}) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setInt({required String key, required int value}) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setString({required String key, required String value}) async {
    assert(key != '');
    assert(value != '');
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  /// Remove a value from stored settings.
  Future<bool> remove(String key) async => await _prefs.remove(key);
}
