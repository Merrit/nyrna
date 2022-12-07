import 'dart:io';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../active_window/active_window.dart';
import '../apps_list/apps_list.dart';
import '../logs/logs.dart';
import '../native_platform/native_platform.dart';
import '../storage/storage_repository.dart';

class HotkeyService {
  final NativePlatform _nativePlatform;
  final StorageRepository _storageRepository;

  const HotkeyService(
    this._nativePlatform,
    this._storageRepository,
  );

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

    log.v('Registered hotkey: ${_hotKey.toStringHelper()}');
  }

  Future<void> _toggleActiveWindow() async {
    log.v('Triggering toggle from hotkey press.');

    await toggleActiveWindow(_nativePlatform, _storageRepository);
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
