/// Contains information about the app's version.
class VersionInfo {
  /// The current version of the app.
  final String currentVersion;

  /// The latest version of the app.
  final String? latestVersion;

  /// Whether an update is available.
  final bool updateAvailable;

  /// Creates a new version info object.
  const VersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.updateAvailable,
  });

  // Empty version info.
  factory VersionInfo.empty() => const VersionInfo(
        currentVersion: '',
        latestVersion: null,
        updateAvailable: false,
      );
}
