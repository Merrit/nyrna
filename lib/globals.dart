import 'package:path_provider/path_provider.dart';

class Globals {
  static const version = '2.0-beta.1';

  static String _tempPath;

  static Future<String> get tempPath async {
    if (_tempPath != null) return _tempPath;
    final _tempDir = await getTemporaryDirectory();
    return _tempDir.path;
  }
}
