import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:helpers/helpers.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../autostart/autostart_service.dart';
import '../../core/core.dart';
import '../../hotkey/hotkey_service.dart';
import '../../storage/storage_repository.dart';
import '../../window/app_window.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

late SettingsCubit settingsCubit;

class SettingsCubit extends Cubit<SettingsState> {
  /// Service for managing autostart.
  final AutostartService _autostartService;
  final HotkeyService _hotkeyService;
  final StorageRepository _storage;

  SettingsCubit._(
    this._autostartService,
    this._hotkeyService,
    this._storage, {
    required SettingsState initialState,
  }) : super(initialState) {
    settingsCubit = this;
    _hotkeyService.addHotkey(state.hotKey);

    AppWindow.instance.preventClose(state.closeToTray);
  }

  static Future<SettingsCubit> init({
    required AutostartService autostartService,
    required HotkeyService hotkeyService,
    required StorageRepository storage,
  }) async {
    final bool autoStart = await storage.getValue('autoStart') ?? false;
    final bool autoRefresh = await storage.getValue('autoRefresh') ?? true;
    final bool closeToTray = await storage.getValue('closeToTray') ?? false;

    HotKey hotkey;
    final String? savedHotkey = await storage.getValue('hotkey');
    if (savedHotkey != null) {
      hotkey = HotKey.fromJson(jsonDecode(savedHotkey));
    } else {
      hotkey = defaultHotkey;
    }

    final bool minimizeWindows =
        await storage.getValue('minimizeWindows') ?? true;
    final int refreshInterval = await storage.getValue('refreshInterval') ?? 5;
    final bool showHiddenWindows =
        await storage.getValue('showHiddenWindows') ?? false;
    final bool startHiddenInTray =
        await storage.getValue('startHiddenInTray') ?? false;

    return SettingsCubit._(
      autostartService,
      hotkeyService,
      storage,
      initialState: SettingsState(
        autoStart: autoStart,
        autoRefresh: autoRefresh,
        closeToTray: closeToTray,
        hotKey: hotkey,
        minimizeWindows: minimizeWindows,
        refreshInterval: refreshInterval,
        showHiddenWindows: showHiddenWindows,
        startHiddenInTray: startHiddenInTray,
        working: false,
      ),
    );
  }

  /// If user wishes to ignore this update, save choice to storage.
  Future<void> ignoreUpdate(String version) async {
    await _storage.saveValue(key: 'ignoredUpdate', value: version);
  }

  Future<void> setRefreshInterval(int interval) async {
    if (interval > 0) {
      await _storage.saveValue(key: 'refreshInterval', value: interval);
      emit(state.copyWith(refreshInterval: interval));
    }
  }

  Future<void> updateAutoRefresh(bool? enabled) async {
    if (enabled == null) return;

    await _storage.saveValue(key: 'autoRefresh', value: enabled);
    emit(state.copyWith(autoRefresh: enabled));
  }

  Future<void> updateCloseToTray([bool? closeToTray]) async {
    if (closeToTray == null) return;

    await AppWindow.instance.preventClose(closeToTray);
    await _storage.saveValue(key: 'closeToTray', value: closeToTray);
    emit(state.copyWith(closeToTray: closeToTray));
  }

  /// Update the preference for auto minimizing windows.
  Future<void> updateMinimizeWindows(bool value) async {
    emit(state.copyWith(minimizeWindows: value));
    await _storage.saveValue(key: 'minimizeWindows', value: value);
  }

  Future<void> updateShowHiddenWindows(bool value) async {
    await _storage.saveValue(key: 'showHiddenWindows', value: value);
    emit(state.copyWith(showHiddenWindows: value));
  }

  Future<void> updateStartHiddenInTray(bool value) async {
    await _storage.saveValue(key: 'startHiddenInTray', value: value);
    emit(state.copyWith(startHiddenInTray: value));
  }

  Future<void> removeHotkey() async {
    await _hotkeyService.removeHotkey(state.hotKey);
  }

  Future<void> resetHotkey() async {
    await _hotkeyService.addHotkey(defaultHotkey);
    emit(state.copyWith(hotKey: defaultHotkey));
    await _storage.deleteValue('hotkey');
  }

  /// Toggle autostart on Desktop.
  Future<void> toggleAutostart() async {
    assert(defaultTargetPlatform.isDesktop);

    emit(state.copyWith(working: true));

    if (state.autoStart) {
      await _autostartService.disable();
    } else {
      await _autostartService.enable();
    }

    emit(state.copyWith(autoStart: !state.autoStart, working: false));
    await _storage.saveValue(key: 'autoStart', value: state.autoStart);
  }

  Future<void> updateHotkey(HotKey newHotKey) async {
    await _hotkeyService.addHotkey(newHotKey);
    emit(state.copyWith(hotKey: newHotKey));
    await _storage.saveValue(
      key: 'hotkey',
      value: jsonEncode(newHotKey.toJson()),
    );
  }
}
