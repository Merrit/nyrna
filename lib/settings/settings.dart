import 'package:shared_preferences/shared_preferences.dart';

/// Globally available settings instance.
Settings settings;

/// Manage all the app settings.
class Settings {
  SharedPreferences _prefs;

  Future<void> initialize() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    return;
  }

  bool get autoRefresh => _prefs.getBool('autoRefresh') ?? false;

  set autoRefresh(bool shouldRefresh) {
    _prefs.setBool('autoRefresh', shouldRefresh);
  }

  int get refreshInterval => _prefs.getInt('refreshInterval') ?? 2;

  set refreshInterval(int interval) {
    if (interval > 0) {
      _prefs.setInt('refreshInterval', interval);
    }
  }

  int get savedProcess => _prefs.getInt('savedProcess');

  Future<void> setSavedProcess(int pid) async {
    await _prefs.setInt('savedProcess', pid);
    return null;
  }

  int get savedWindowId => _prefs.getInt('savedWindowId');

  Future<void> setSavedWindowId(int id) async {
    await _prefs.setInt('savedWindowId', id);
    return null;
  }
}
