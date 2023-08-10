import 'dart:io';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import '../core/helpers/json_converters.dart';
import '../logs/logs.dart';
import '../storage/storage_repository.dart';

/// Represents the main window of the app.
class AppWindow {
  final StorageRepository _storage;

  static late final AppWindow instance;

  AppWindow(this._storage) {
    instance = this;
  }

  void initialize() {
    windowManager.waitUntilReadyToShow().then((_) async {
      final bool? startHiddenInTray =
          await _storage.getValue('startHiddenInTray');

      if (startHiddenInTray != true) {
        await show();
      }
    });
  }

  Future<void> preventClose(bool shouldPreventClose) async {
    await windowManager.setPreventClose(shouldPreventClose);
  }

  /// Closes the app.
  void close() => exit(0);

  /// Hides the app window.
  Future<void> hide() async {
    await saveWindowSize();
    await windowManager.hide();
  }

  /// Reset the app window position.
  ///
  /// This can be useful if the window has been moved off-screen.
  Future<void> reset() async {
    await windowManager.center();
  }

  /// Shows the app window.
  Future<void> show() async {
    final Rect? savedWindowSize = await getSavedWindowSize();
    if (savedWindowSize != null) windowManager.setBounds(savedWindowSize);
    await windowManager.show();
  }

  Future<void> saveWindowSize() async {
    final windowInfo = await windowManager.getBounds();
    final rectJson = windowInfo.toJson();
    log.i('Saving window info:\n$rectJson');
    await _storage.saveValue(key: 'windowSize', value: rectJson);
  }

  /// Returns if available the last window size and position.
  Future<Rect?> getSavedWindowSize() async {
    final String? rectJson = await _storage.getValue('windowSize');
    if (rectJson == null) return null;
    log.i('Retrieved saved window info:\n$rectJson');
    final windowRect = RectConverter.fromJson(rectJson);
    return windowRect;
  }
}
