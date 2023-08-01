import 'dart:async';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../logs/logs.dart';

/// The default hotkey to use if none is set.
final HotKey defaultHotkey = HotKey(KeyCode.pause);

class HotkeyService {
  /// Stream that fires when a hotkey is triggered.
  ///
  /// Allows dependent services to react when a hotkey is triggered.
  Stream<HotKey> get hotkeyTriggeredStream =>
      _hotkeyTriggeredStreamController.stream;

  /// Controller for the hotkey triggered stream.
  final _hotkeyTriggeredStreamController = StreamController<HotKey>.broadcast();

  Future<void> addHotkey(HotKey hotKey) async {
    await hotKeyManager.unregister(hotKey);

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        log.i('Hotkey triggered: ${hotKey.toStringHelper()}');
        _hotkeyTriggeredStreamController.add(hotKey);
      },
    );

    log.i('Registered hotkey: ${hotKey.toStringHelper()}');
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
