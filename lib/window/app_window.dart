import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import '../logs/logging_manager.dart';
import '../storage/storage_repository.dart';

class AppWindow {
  final StorageRepository _storageRepository;

  const AppWindow(this._storageRepository);

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions();
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
      await setWindowSizeAndPosition();
      await windowManager.show();
    });
  }

  void close() => exit(0);

  Future<void> hide() async => await windowManager.hide();

  /// Reset window size and position to default.
  ///
  /// This will also center the window on the primary screen.
  /// Useful if the window is somehow moved off screen.
  Future<void> reset() async {
    final screenConfigurationId = await _getScreenConfigurationId();
    await _storageRepository.deleteValue(
      screenConfigurationId,
      storageArea: 'windowSizeAndPosition',
    );
    await setWindowSizeAndPosition();
  }

  /// Saves the current window size and position to storage.
  ///
  /// Allows us to restore the window size and position on the next run.
  Future<void> saveWindowSizeAndPosition() async {
    final windowInfo = await window_size.getWindowInfo();
    final Rect frame = windowInfo.frame;
    final String screenConfigurationId = await _getScreenConfigurationId();

    log.t(
      'Saving window size and position. \n'
      'Screen configuration ID: $screenConfigurationId \n'
      'Window bounds: left: ${frame.left}, top: ${frame.top}, '
      'width: ${frame.width}, height: ${frame.height}',
    );

    await _storageRepository.saveValue(
      storageArea: 'windowSizeAndPosition',
      key: screenConfigurationId,
      value: frame.toJson(),
    );
  }

  /// Sets the window size and position.
  ///
  /// If the window size and position has been saved previously, it will be
  /// restored. Otherwise, the window will be centered on the primary screen.
  Future<void> setWindowSizeAndPosition() async {
    /// Window size and position is not supported on Windows.
    /// (Works fine on Linux.)
    ///
    /// The window doesn't account for scaling correctly, and it doesn't
    /// seem worthwhile to spend a lot of time on this until they have finished
    /// their work on the new Flutter multi window support that is causing all
    /// kinds of changes and depreciations.
    if (Platform.isWindows) return;

    log.t('Setting window size and position.');
    final screenConfigurationId = await _getScreenConfigurationId();
    final windowInfo = await window_size.getWindowInfo();
    final Rect currentWindowFrame = windowInfo.frame;

    final String? savedWindowRectJson = await _storageRepository.getValue(
      screenConfigurationId,
      storageArea: 'windowSizeAndPosition',
    );

    Rect targetWindowFrame;
    if (savedWindowRectJson != null) {
      targetWindowFrame = _rectFromJson(savedWindowRectJson);
    } else {
      targetWindowFrame = const Rect.fromLTWH(0, 0, 530, 600);
    }

    if (targetWindowFrame == currentWindowFrame) {
      log.t('Target matches current window frame, nothing to do.');
      return;
    }

    log.t(
      'Screen configuration ID: $screenConfigurationId \n'
      'Current window bounds: \n'
      'left: ${currentWindowFrame.left}, top: ${currentWindowFrame.top}, '
      'width: ${currentWindowFrame.width}, '
      'height: ${currentWindowFrame.height} \n'
      '~~~\n'
      'Target window bounds: \n'
      'left: ${targetWindowFrame.left}, top: ${targetWindowFrame.top}, '
      'width: ${targetWindowFrame.width}, height: ${targetWindowFrame.height}',
    );

    window_size.setWindowFrame(targetWindowFrame);

    // If first run, center window.
    if (savedWindowRectJson == null) await windowManager.center();
  }

  Future<void> show() async => await windowManager.show();

  /// Returns a unique identifier for the current configuration of screens.
  ///
  /// By using this, we can save the window position for each screen
  /// configuration, and then restore the window position for the current
  /// screen configuration.
  Future<String> _getScreenConfigurationId() async {
    final screens = await window_size.getScreenList();
    final StringBuffer buffer = StringBuffer();
    for (final screen in screens) {
      buffer
        ..write(screen.frame.left)
        ..write(screen.frame.top)
        ..write(screen.frame.width)
        ..write(screen.frame.height)
        ..write(screen.scaleFactor);
    }
    return buffer.toString();
  }
}

extension _RectHelper on Rect {
  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    };
  }

  String toJson() => json.encode(toMap());
}

Rect _rectFromJson(String source) {
  final Map<String, dynamic> map = json.decode(source);
  return Rect.fromLTWH(
    map['left'],
    map['top'],
    map['width'],
    map['height'],
  );
}
