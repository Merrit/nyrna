import 'package:shared_preferences/shared_preferences.dart';

/// Globally available settings instance.
Settings settings;

/// Manage all the app settings.
class Settings {
  SharedPreferences prefs;

  Future<void> initialize() async {
    if (prefs != null) return;
    prefs = await SharedPreferences.getInstance();
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

  int get savedProcess => prefs.getInt('savedProcess');

  Future<void> setSavedProcess(int pid) async {
    await prefs.setInt('savedProcess', pid);
  }

  int get savedWindowId => prefs.getInt('savedWindowId');

  Future<void> setSavedWindowId(int id) async {
    await prefs.setInt('savedWindowId', id);
  }
}
