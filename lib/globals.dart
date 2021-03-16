import 'package:path_provider/path_provider.dart';

class Globals {
  static String version = '';

  static String _tempPath;

  static Future<String> get tempPath async {
    if (_tempPath != null) return _tempPath;
    final _tempDir = await getTemporaryDirectory();
    return _tempDir.path;
  }
}
