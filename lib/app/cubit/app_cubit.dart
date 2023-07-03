import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../logs/logs.dart';
import '../../storage/storage_repository.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

/// A function that launches a [url] in the default browser.
typedef LaunchUrl = Future<bool> Function(
  Uri url, {
  url_launcher.LaunchMode mode,
  url_launcher.WebViewConfiguration webViewConfiguration,
  String? webOnlyWindowName,
});

/// Handles general app-related functionality, like launching urls and checking
/// for app updates.
class AppCubit extends Cubit<AppState> {
  final StorageRepository _storageRepository;
  final LaunchUrl _launchUrl;

  static late AppCubit instance;

  AppCubit(
    this._storageRepository, [
    LaunchUrl? launchUrl,
  ])  : _launchUrl = launchUrl ?? url_launcher.launchUrl,
        super(AppState.initial()) {
    instance = this;
    init();
  }

  Future<void> init() async {
    bool? firstRun = await _storageRepository.getValue('firstRun');
    firstRun ??= true; // If not in storage, this is first run.

    emit(state.copyWith(
      firstRun: firstRun,
    ));
  }

  Future<void> userAcceptedDisclaimer() async {
    await _storageRepository.saveValue(key: 'firstRun', value: false);
    emit(state.copyWith(firstRun: false));
  }

  /// Launch the requested [url] in the default browser.
  Future<bool> launchURL(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      log.e('Unable to parse url: $url');
      return false;
    }

    try {
      return await _launchUrl(uri);
    } on PlatformException catch (e) {
      log.e('Could not launch url: $url', e);
      return false;
    }
  }
}
