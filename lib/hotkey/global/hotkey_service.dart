import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../logs/logs.dart';

/// The default hotkey to use if none is set.
final HotKey defaultHotkey = HotKey(key: PhysicalKeyboardKey.pause);

/// Handles global (system-wide) hotkeys.
class HotkeyService {
  /// Stream that fires when a hotkey is triggered.
  ///
  /// Allows dependent services to react when a hotkey is triggered.
  Stream<HotKey> get hotkeyTriggeredStream => _hotkeyTriggeredStreamController.stream;

  /// Controller for the hotkey triggered stream.
  final _hotkeyTriggeredStreamController = StreamController<HotKey>.broadcast();

  Future<void> addHotkey(HotKey hotKey) async {
    if (hotKeyManager.registeredHotKeyList.contains(hotKey)) {
      log.w('Hotkey already registered: ${hotKey.debugName}');
      return;
    }

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        log.i('Hotkey triggered: ${hotKey.debugName}');
        _hotkeyTriggeredStreamController.add(hotKey);
      },
    );

    log.i('Registered hotkey: ${hotKey.debugName}');
  }

  Future<void> removeHotkey(HotKey hotkey) async {
    await hotKeyManager.unregister(hotkey);
  }
}
