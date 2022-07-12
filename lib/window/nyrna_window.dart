import 'dart:io';
import 'dart:ui';

import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:window_size/window_size.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings.dart';

class NyrnaWindow {
  NyrnaWindow() {
    _listenForWindowClose();
  }

  void _listenForWindowClose() {
    if (!Platform.isLinux) return;

    /// For now using `flutter_window_close` on Linux, because the
    /// `onWindowClose` from `window_manager` is only working on Windows for
    /// some reason. Probably best to switch to only using `window_manager` if
    /// it starts also working on Linux in the future.
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (!settingsCubit.state.closeToTray) return true;

      hide();
      await settingsCubit.saveWindowSize();
      return false;
    });
  }

  Future<void> preventClose(bool shouldPreventClose) async {
    await windowManager.setPreventClose(shouldPreventClose);
  }

  void close() => exit(0);

  Future<void> hide() async {
    setWindowVisibility(visible: false);
    await settingsCubit.saveWindowSize();
  }

  Future<void> show() async {
    final Rect? savedWindowSize = await settingsCubit.savedWindowSize();
    if (savedWindowSize != null) setWindowFrame(savedWindowSize);

    setWindowVisibility(visible: true);
  }
}
