import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart' as semver;

import '../logs/logs.dart';

/// Check app versions.
class AppVersion {
  final PackageInfo _packageInfo;

  AppVersion(this._packageInfo);

  /// The application version that is currently running.
  ///
  /// Example: `1.0.0`.
  String running() => _packageInfo.version;

  Future<bool> updateAvailable() async {
    try {
      final runningVersion = semver.Version.parse(_packageInfo.version);
      final latestVersion = semver.Version.parse(await latest());
      return (runningVersion < latestVersion) ? true : false;
    } on Exception {
      return false;
    }
  }

  /// Cached variable for `latest()`.
  String _latest = '';

  /// Gets the latest version from the GitHub tag.
  Future<String> latest() async {
    if (_latest != '') return _latest;

    final uri = Uri.parse(
      'https://api.github.com/repos/merrit/nyrna/releases',
    );

    final Response response;

    try {
      response = await http.get(
        uri,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
    } on Exception catch (e) {
      log.w('Issue getting latest version info from GitHub: $e\n');
      return '';
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      final data = List<Map>.from(json);
      final tag = data.firstWhere((element) => element['prerelease'] == false);
      final tagName = tag['tag_name'] as String;
      _latest = parseVersionTag(tagName);
    } else {
      log.w(
        'Issue getting latest version info from GitHub, '
        'status code: ${response.statusCode}\n',
      );
    }

    return _latest;
  }

  /// Returns the version number without the leading `v` or any postfix.
  ///
  /// Examples:
  /// `v1.2.3` becomes `1.2.3`.
  /// `v1.2.3-beta` becomes `1.2.3`.
  @visibleForTesting
  String parseVersionTag(String tag) {
    final version = tag.split('v').last.split('-').first;
    return version;
  }
}
