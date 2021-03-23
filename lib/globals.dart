import 'package:path_provider/path_provider.dart';

/// Globally accessible variables.
class Globals {
  /// Nyrna's current running version.
  static String version = '';

  static String _tempPath;

  /// The system's temp path, for example: `/tmp`.
  static Future<String> get tempPath async {
    if (_tempPath != null) return _tempPath;
    final _tempDir = await getTemporaryDirectory();
    return _tempDir.path;
  }
}
