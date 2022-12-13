import 'package:url_launcher/url_launcher.dart';

/// Launches URLs on the host platform.
class UrlLauncher {
  Future<bool> canLaunch(Uri uri) async => await canLaunchUrl(uri);

  Future<bool> launch(Uri uri) async => await launchUrl(uri);
}
