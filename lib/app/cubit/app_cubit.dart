import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import '../../logs/logs.dart';
import '../app.dart';

part 'app_state.dart';

/// Handles general app-related functionality, like launching urls and checking
/// for app updates.
class AppCubit extends Cubit<AppState> {
  final CanLaunchUrlFunction _canLaunchUrl;
  final LaunchUrlFunction _launchUrl;

  static late AppCubit instance;

  AppCubit(
    this._canLaunchUrl,
    this._launchUrl,
  ) : super(const AppState()) {
    instance = this;
  }

  /// Launch the requested [url] in the default browser.
  Future<bool> launchURL(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      log.e('Unable to parse url: $url');
      return false;
    }

    if (!await _canLaunchUrl(uri)) return false;

    try {
      return await _launchUrl(uri);
    } on PlatformException catch (e) {
      log.e('Could not launch url: $url', e);
      return false;
    }
  }
}
