import 'dart:io';
import 'dart:ui';

import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:window_manager/window_manager.dart';

import '../core/helpers/json_converters.dart';
import '../logs/logs.dart';
import '../settings/settings.dart';
import '../storage/storage_repository.dart';

class NyrnaWindow {
  final StorageRepository _storage;

  static late final NyrnaWindow instance;

  NyrnaWindow(this._storage) {
    instance = this;
    _listenForWindowClose();
  }

  void _listenForWindowClose() {
    if (!Platform.isLinux) return;

    /// For now using `flutter_window_close` on Linux, because the
    /// `onWindowClose` from `window_manager` is only working on Windows for
    /// some reason. Probably best to switch to only using `window_manager` if
    /// it starts also working on Linux in the future.
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      await hide();
      final shouldExitProgram = (settingsCubit.state.closeToTray) //
          ? false
          : true;

      return shouldExitProgram;
    });
  }

  Future<void> preventClose(bool shouldPreventClose) async {
    await windowManager.setPreventClose(shouldPreventClose);
  }

  void close() => exit(0);

  Future<void> hide() async {
    await saveWindowSize();
    await windowManager.hide();
  }

  Future<void> show() async {
    final Rect? savedWindowSize = await getSavedWindowSize();
    if (savedWindowSize != null) windowManager.setBounds(savedWindowSize);
    await windowManager.show();
  }

  Future<void> saveWindowSize() async {
    final windowInfo = await windowManager.getBounds();
    final rectJson = windowInfo.toJson();
    log.v('Saving window info:\n$rectJson');
    await _storage.saveValue(key: 'windowSize', value: rectJson);
  }

  /// Returns if available the last window size and position.
  Future<Rect?> getSavedWindowSize() async {
    String? rectJson = await _storage.getValue('windowSize');
    if (rectJson == null) return null;
    log.v('Retrieved saved window info:\n$rectJson');
    final windowRect = RectConverter.fromJson(rectJson);
    return windowRect;
  }
}
