import 'package:url_launcher/url_launcher.dart';

/// For DI of the [canLaunchUrl] function from [url_launcher].
typedef CanLaunchUrlFunction = Future<bool> Function(Uri url);

/// For DI of the [launchUrl] function from [url_launcher].
typedef LaunchUrlFunction = Future<bool> Function(
  Uri url, {
  LaunchMode mode,
  WebViewConfiguration webViewConfiguration,
  String? webOnlyWindowName,
});
