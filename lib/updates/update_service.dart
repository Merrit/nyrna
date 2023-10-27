import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../logs/logs.dart';
import 'updates.dart';

/// Service for checking for version info and updates.
class UpdateService {
  /// Gets inforamation about the current and latest versions of the app.
  Future<VersionInfo> getVersionInfo() async {
    final currentVersion = await _getCurrentVersion();
    final latestVersion = await _getLatestVersion();

    // If the latest version is null, then we couldn't get the info from GitHub.
    // In this case, we'll just assume there is no update available.
    // If the latest version is a prerelease, then we'll also assume there is no
    // update available.
    bool updateAvailable;
    if (latestVersion == null) {
      updateAvailable = false;
    } else if (latestVersion.isPreRelease) {
      updateAvailable = false;
    } else {
      updateAvailable = currentVersion < latestVersion;
    }

    return VersionInfo(
      currentVersion: currentVersion.toString(),
      latestVersion: latestVersion?.toString(),
      updateAvailable: updateAvailable,
    );
  }

  /// Gets the current version of the app.
  Future<Version> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return Version.parse(packageInfo.version);
  }

  /// Gets the latest version of the app.
  Future<Version?> _getLatestVersion() async {
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
      return null;
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      final data = List<Map>.from(json);
      final tag = data.firstWhere((element) => element['prerelease'] == false);
      final tagName = tag['tag_name'] as String;
      final version = _parseVersionTag(tagName);
      return Version.parse(version);
    } else {
      log.w('Issue getting latest version info from GitHub, '
          'status code: ${response.statusCode}\n');
    }

    return null;
  }

  /// Returns the version number without the leading `v` or any postfix.
  ///
  /// Examples:
  /// `v1.2.3` becomes `1.2.3`.
  /// `v1.2.3-beta` becomes `1.2.3`.
  String _parseVersionTag(String tag) {
    final version = tag.split('v').last.split('-').first;
    return version;
  }
}
