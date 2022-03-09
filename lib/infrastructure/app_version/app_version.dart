import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

/// Check app versions.
class AppVersion {
  final PackageInfo _packageInfo;

  AppVersion(this._packageInfo);

  /// The application version that is currently running.
  ///
  /// Example: `1.0.0`.
  String running() => _packageInfo.version;

  Future<bool> updateAvailable() async {
    final _runningVersion = semver.Version.parse(_packageInfo.version);
    final _latestVersion = semver.Version.parse(await latest());
    return (_runningVersion < _latestVersion) ? true : false;
  }

  /// Cached variable for `latest()`.
  String _latest = '';

  /// Gets the latest version from the GitHub tag.
  Future<String> latest() async {
    if (_latest != '') return _latest;
    final uri = Uri.parse(
      'https://api.github.com/repos/merrit/nyrna/releases',
    );
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      final data = List<Map>.from(json);
      final tag = data.firstWhere((element) => element['prerelease'] == false);
      final tagName = tag['tag_name'] as String;
      // Strip the leading `v` and anything trailing.
      // May need to be updated if we starting using postfixes like `beta`.
      _latest = tagName.substring(1, 6);
    } else {
      print('Issue getting latest version info from GitHub, '
          'status code: ${response.statusCode}\n');
    }
    return _latest;
  }
}
