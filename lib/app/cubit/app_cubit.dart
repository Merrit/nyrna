import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logs/logs.dart';
import '../../storage/storage_repository.dart';
import '../../url_launcher/url_launcher.dart';

part 'app_state.dart';

/// Handles general app-related functionality, like launching urls and checking
/// for app updates.
class AppCubit extends Cubit<AppState> {
  final StorageRepository _storageRepository;
  final UrlLauncher _urlLauncher;

  static late AppCubit instance;

  AppCubit(
    this._storageRepository,
    this._urlLauncher,
  ) : super(AppState.initial()) {
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

    if (!await _urlLauncher.canLaunch(uri)) return false;

    try {
      return await _urlLauncher.launch(uri);
    } on PlatformException catch (e) {
      log.e('Could not launch url: $url', e);
      return false;
    }
  }
}
