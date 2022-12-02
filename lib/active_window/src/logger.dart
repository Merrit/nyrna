import 'dart:io';

/// We log to a temp file on the system since this runs
/// with neiter a console nor a GUI, giving us a way to debug issues
/// which only manifest in a release build.
class Logger {
  static bool shouldLog = false;

  static Future<void> log(String value, [bool? override]) async {
    if (shouldLog || override == true) {
      final tempDir = Directory.systemTemp.path;
      final file = File('$tempDir/nyrna_toggle_log.txt');
      await file.writeAsString(
        '$value \n',
        mode: FileMode.append,
        flush: true,
      );
    }
  }
}
