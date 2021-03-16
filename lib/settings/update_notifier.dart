import 'package:http/http.dart' as http;
import 'package:nyrna/globals.dart';
import 'package:nyrna/settings/settings.dart';

/// Check if updates to Nyrna are available.
class UpdateNotifier {
  /// If update is available returns true.
  Future<bool> get updateAvailable async {
    if (!_shouldCheck()) return false;
    final latest = await latestVersion();
    if (latest == '') return false;
    if (settings.ignoredUpdate == latest) return false;
    return (Globals.version == latest) ? false : true;
  }

  /// Only check for update once a day.
  bool _shouldCheck() {
    final savedCheck = settings.prefs.getString('checkedUpdate');
    if (savedCheck == null) return true;
    final lastChecked = DateTime.tryParse(savedCheck);
    if (lastChecked == null) return true;
    final timestamp = DateTime.now();
    // Add 1 day to the saved timestamp, check if 1 day has passed.
    return timestamp.isAfter(lastChecked.add(Duration(days: 1)));
  }

  /// Checks the VERSION file at GitHub to get the latest version number.
  Future<String> latestVersion() async {
    final uri =
        Uri.https('raw.githubusercontent.com', '/Merrit/nyrna/master/VERSION');
    if (uri == null) return '';
    final result = await http.read(uri);
    return result.trim();
  }

  /// If user wishes to ignore this update, save to SharedPreferences.
  void ignoreVersion(String version) {
    settings.prefs.setString('ignoredUpdate', version);
  }
}
