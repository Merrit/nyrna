import 'dart:async';
import 'dart:io';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../active_window/active_window.dart';
import '../logs/logs.dart';

class HotkeyService {
  final ActiveWindow _activeWindow;

  HotkeyService(
    this._activeWindow,
  );

  /// Stream that fires when the hotkey is triggered.
  ///
  /// Allows dependent services to react to the hotkey being triggered.
  Stream<bool> get hotkeyTriggeredStream =>
      _hotkeyTriggeredStreamController.stream;

  /// Controller for the refresh stream.
  final _hotkeyTriggeredStreamController = StreamController<bool>.broadcast();

  Future<void> removeHotkey() async {
    await hotKeyManager.unregisterAll();
  }

  Future<void> updateHotkey(HotKey hotKey) async {
    // Hotkey service not working properly on Linux..
    // - The method channel doesn't seem able to register `Pause` at all.
    // - Hotkeys don't seem to work on Wayland.
    if (Platform.isLinux) return;

    await hotKeyManager.unregisterAll();

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) => _toggleActiveWindow(),
    );

    log.v('Registered hotkey: ${hotKey.toStringHelper()}');
  }

  Future<bool> _toggleActiveWindow() async {
    log.v('Triggering toggle from hotkey press.');
    final successful = await _activeWindow.toggle();
    _hotkeyTriggeredStreamController.add(true);
    return successful;
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
