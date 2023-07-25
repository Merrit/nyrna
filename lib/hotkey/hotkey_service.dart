import 'dart:async';
import 'dart:io';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../logs/logs.dart';

class HotkeyService {
  /// Stream that fires when a hotkey is triggered.
  ///
  /// Allows dependent services to react when a hotkey is triggered.
  Stream<HotKey> get hotkeyTriggeredStream =>
      _hotkeyTriggeredStreamController.stream;

  /// Controller for the hotkey triggered stream.
  final _hotkeyTriggeredStreamController = StreamController<HotKey>.broadcast();

  Future<void> addHotkey(HotKey hotKey) async {
    // Hotkey service not working properly on Linux..
    // - The method channel doesn't seem able to register `Pause` at all.
    // - Hotkeys don't seem to work on Wayland.
    if (Platform.isLinux) return;

    await hotKeyManager.unregister(hotKey);

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        log.v('Hotkey triggered: ${hotKey.toStringHelper()}');
        _hotkeyTriggeredStreamController.add(hotKey);
      },
    );

    log.v('Registered hotkey: ${hotKey.toStringHelper()}');
  }

  Future<void> removeHotkey(HotKey hotkey) async {
    await hotKeyManager.unregister(hotkey);
  }
}

extension HotKeyHelper on HotKey {
  String toStringHelper() {
    String hotkeyString = '';
    for (var modifier in modifiers ?? <KeyModifier>[]) {
      hotkeyString += '${modifier.keyLabel} + ';
    }

    hotkeyString += keyCode.keyLabel;
    return hotkeyString;
  }
}
