import 'dart:io';
import 'dart:ui';

import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:window_size/window_size.dart';

import '../settings/settings.dart';

class NyrnaWindow {
  NyrnaWindow() {
    _listenForWindowClose();
  }

  void _listenForWindowClose() {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (!settingsCubit.state.closeToTray) return true;

      hide();
      await settingsCubit.saveWindowSize();
      return false;
    });
  }

  void close() => exit(0);

  void hide() => setWindowVisibility(visible: false);

  Future<void> show() async {
    final Rect? savedWindowSize = await settingsCubit.savedWindowSize();
    if (savedWindowSize != null) setWindowFrame(savedWindowSize);

    setWindowVisibility(visible: true);
  }
}
