import 'package:nyrna/application/theme/enums/app_theme.dart';
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

  /// The unique hex ID of the window suspended via [ActiveWindow.toggle()].
  int? get savedWindowId => _prefs!.getInt('savedWindowId');

  Future<void> setSavedWindowId(int id) async {
    await _prefs!.setInt('savedWindowId', id);
  }

  /// If user has ignored an update that version number is saved here.
  String? get ignoredUpdate => _prefs!.getString('ignoredUpdate');

  static const int _defaultIconColor = 2617291775;

  int get iconColor => _prefs!.getInt('iconColor') ?? _defaultIconColor;

  Future<void> setIconColor(int color) async {
    await _prefs!.setInt('iconColor', color);
  }

  AppTheme get appTheme {
    final savedTheme = _prefs?.getString('appTheme');
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
    _prefs?.setString('appTheme', appTheme.toString());
  }
}
