import 'dart:io';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../active_window/active_window.dart';
import '../apps_list/apps_list.dart';
import '../logs/logs.dart';

class HotkeyService {
  final ActiveWindow _activeWindow;

  const HotkeyService(
    this._activeWindow,
  );

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
    await appsListCubit.manualRefresh();
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
