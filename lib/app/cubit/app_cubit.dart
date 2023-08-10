import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../logs/logs.dart';
import '../../storage/storage_repository.dart';
import '../../system_tray/system_tray.dart';
import '../../updates/updates.dart';
import '../../window/app_window.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

/// Handles general app-related functionality, like launching urls and checking
/// for app updates.
class AppCubit extends Cubit<AppState> {
  /// Service for managing the app window.
  final AppWindow _appWindow;

  /// Service for fetching release notes.
  final ReleaseNotesService _releaseNotesService;

  final StorageRepository _storageRepository;

  /// Service for managing the system tray.
  final SystemTrayManager _systemTrayManager;

  /// Service for fetching version info.
  final UpdateService _updateService;

  static late AppCubit instance;

  AppCubit(
    this._appWindow,
    this._releaseNotesService,
    this._storageRepository,
    this._systemTrayManager,
    this._updateService,
  ) : super(AppState.initial()) {
    instance = this;
    _init();
  }

  /// Initializes the cubit.
  ///
  /// Lazy loading is used instead of awaiting on a constructor to avoid
  /// blocking the UI, since none of the data fetched here is critical.
  Future<void> _init() async {
    await _checkForFirstRun();
    await _fetchVersionData();
    await _fetchReleaseNotes();
    _listenToSystemTrayEvents();
  }

  /// Checks if this is the first run of the app.
  Future<void> _checkForFirstRun() async {
    final firstRun = await _storageRepository.getValue('firstRun');
    if (firstRun == null) {
      emit(state.copyWith(firstRun: true));
      _storageRepository.saveValue(key: 'firstRun', value: false);
    }
  }

  /// Fetches version data from the update service.
  Future<void> _fetchVersionData() async {
    final versionInfo = await _updateService.getVersionInfo();
    emit(state.copyWith(
      runningVersion: versionInfo.currentVersion,
      updateVersion: versionInfo.latestVersion,
      updateAvailable: versionInfo.updateAvailable,
      showUpdateButton:
          (defaultTargetPlatform.isDesktop && versionInfo.updateAvailable),
    ));
  }

  /// Fetches release notes from the release notes service.
  Future<void> _fetchReleaseNotes() async {
    if (state.firstRun) return;

    final String? lastReleaseNotesVersionShown =
        await _storageRepository.getValue('lastReleaseNotesVersionShown');

    if (lastReleaseNotesVersionShown == state.runningVersion) return;

    final releaseNotes = await _releaseNotesService.getReleaseNotes(
      'v${state.runningVersion}',
    );

    if (releaseNotes == null) return;

    emit(state.copyWith(releaseNotes: releaseNotes));
  }

  /// Listens and reacts to system tray events.
  void _listenToSystemTrayEvents() {
    _systemTrayManager.eventStream.listen((event) {
      switch (event) {
        case SystemTrayEvent.exit:
          _appWindow.close();
          break;
        case SystemTrayEvent.windowHide:
          _appWindow.hide();
          break;
        case SystemTrayEvent.windowReset:
          _appWindow.reset();
          break;
        case SystemTrayEvent.windowShow:
          _appWindow.show();
          break;
      }
    });
  }

  /// The user has dismissed the release notes dialog.
  Future<void> dismissReleaseNotesDialog() async {
    emit(state.copyWith(releaseNotes: null));

    await _storageRepository.saveValue(
      key: 'lastReleaseNotesVersionShown',
      value: state.runningVersion,
    );
  }

  Future<void> userAcceptedDisclaimer() async {
    await _storageRepository.saveValue(key: 'firstRun', value: false);
    emit(state.copyWith(firstRun: false));
  }

  /// Launch the requested [url] in the default browser.
  Future<bool> launchURL(String url) async {
    // Very difficult to mock top-level functions, so we just skip this in tests.
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;

    final uri = Uri.tryParse(url);

    if (uri == null) {
      log.e('Unable to parse url: $url');
      return false;
    }

    try {
      return await url_launcher.launchUrl(uri);
    } on PlatformException catch (e) {
      log.e('Could not launch url: $url', error: e);
      return false;
    }
  }
}
