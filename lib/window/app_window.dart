import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:window_size/window_size.dart' show PlatformWindow, Screen;

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
    // final windowInfo = await window_size.getWindowInfo();
    // final Rect frame = windowInfo.frame;
    // final String screenConfigurationId = await _getScreenConfigurationId();

    // log.t(
    //   'Saving window size and position. \n'
    //   'Screen configuration ID: $screenConfigurationId \n'
    //   'Window bounds: left: ${frame.left}, top: ${frame.top}, '
    //   'width: ${frame.width}, height: ${frame.height}',
    // );

    // await _storageRepository.saveValue(
    //   storageArea: 'windowSizeAndPosition',
    //   key: screenConfigurationId,
    //   value: frame.toJson(),
    // );

    // `window_size` uses screen coordinates, so we need to convert them to
    // logical pixels using the screen's `scaleFactor`.
    final String screenConfigurationId = await _getScreenConfigurationId();
    final windowInfo = await window_size.getWindowInfo();

    double? scaleFactor = windowInfo.screen?.scaleFactor ?? 1.0;
    if (scaleFactor == 0) scaleFactor = 1.0;

    Rect frame = windowInfo.frame;
    frame = Rect.fromLTWH(
      frame.left / scaleFactor,
      frame.top / scaleFactor,
      frame.width / scaleFactor,
      frame.height / scaleFactor,
    );
  }

  /// Sets the window size and position.
  ///
  /// If the window size and position has been saved previously, it will be
  /// restored. Otherwise, the window will be centered on the primary screen.
  Future<void> setWindowSizeAndPosition() async {
    log.t('Setting window size and position.');
    final screenConfigurationId = await _getScreenConfigurationId();
    final windowInfo = await window_size.getWindowInfo();
    final Rect currentWindowFrame = windowInfo.frame;
    final double scaleFactor = windowInfo.scaleFactor;

    final String? savedWindowRectJson = await _storageRepository.getValue(
      screenConfigurationId,
      storageArea: 'windowSizeAndPosition',
    );

    Rect targetWindowFrame;
    // Adjust for the scale factor.
    if (savedWindowRectJson != null) {
      targetWindowFrame = _rectFromJson(savedWindowRectJson);
      targetWindowFrame = Rect.fromLTWH(
        targetWindowFrame.left,
        targetWindowFrame.top,
        targetWindowFrame.width * scaleFactor,
        targetWindowFrame.height * scaleFactor,
      );
    } else {
      targetWindowFrame = Rect.fromLTWH(
        0,
        0,
        530 * scaleFactor,
        600 * scaleFactor,
      );
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

extension _PlatformWindowHelper on PlatformWindow {
  Map<String, dynamic> toMap() {
    return {
      'frame': frame.toMap(),
      'scaleFactor': scaleFactor,
      'screen': screen?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}

PlatformWindow _platformWindowFromJson(String source) {
  final Map<String, dynamic> map = json.decode(source);
  return PlatformWindow(
    _rectFromJson(map['frame']),
    map['scaleFactor'],
    map['screen'] != null ? _screenFromJson(map['screen']) : null,
  );
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

extension _ScreenHelper on Screen {
  Map<String, dynamic> toMap() {
    return {
      'frame': frame.toMap(),
      'visibleFrame': visibleFrame.toMap(),
      'scaleFactor': scaleFactor,
    };
  }

  String toJson() => json.encode(toMap());
}

Screen _screenFromJson(String source) {
  final Map<String, dynamic> map = json.decode(source);
  return Screen(
    _rectFromJson(map['frame']),
    _rectFromJson(map['visibleFrame']),
    map['scaleFactor'],
  );
}
