import 'dart:io';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:logging/logging.dart';

import '../active_window/active_window.dart';
import '../apps_list/apps_list.dart';
import '../native_platform/native_platform.dart';

class HotkeyService {
  final _log = Logger('HotkeyService');

  Future<void> removeHotkey() async {
    await hotKeyManager.unregisterAll();
  }

  Future<void> updateHotkey(HotKey _hotKey) async {
    // Hotkey service not working properly on Linux..
    // - The method channel doesn't seem able to register `Pause` at all.
    // - Hotkeys don't seem to work on Wayland.
    if (Platform.isLinux) return;

    await hotKeyManager.unregisterAll();

    await hotKeyManager.register(
      _hotKey,
      keyDownHandler: (hotKey) => _toggleActiveWindow(),
    );

    _log.info('Registered hotkey: ${_hotKey.toStringHelper()}');
  }

  Future<void> _toggleActiveWindow() async {
    _log.info('Triggering toggle from hotkey press.');

    await toggleActiveWindow(nativePlatform: NativePlatform());
    await appsListCubit.manualRefresh();
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
