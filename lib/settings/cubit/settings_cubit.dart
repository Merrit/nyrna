import 'dart:convert';
import 'dart:ui';

import 'package:desktop_integration/desktop_integration.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_size/window_size.dart' show PlatformWindow;

import '../../apps_list/apps_list.dart';
import '../../core/core.dart';
import '../../hotkey/hotkey_service.dart';
import '../../storage/storage_repository.dart';
import '../../window/nyrna_window.dart';

part 'settings_state.dart';

late SettingsCubit settingsCubit;

class SettingsCubit extends Cubit<SettingsState> {
  final DesktopIntegration _desktopIntegration;
  final Future<PlatformWindow> Function() _getWindowInfo;
  final HotkeyService _hotkeyService;
  final NyrnaWindow _nyrnaWindow;
  final StorageRepository _storage;

  SettingsCubit._(
    this._desktopIntegration,
    this._getWindowInfo,
    this._hotkeyService,
    this._nyrnaWindow,
    this._storage, {
    required SettingsState initialState,
  }) : super(initialState) {
    settingsCubit = this;
    _hotkeyService.updateHotkey(state.hotKey);
    _nyrnaWindow.preventClose(state.closeToTray);
  }

  static Future<SettingsCubit> init({
    required DesktopIntegration desktopIntegration,
    required Future<PlatformWindow> Function() getWindowInfo,
    required HotkeyService hotkeyService,
    required NyrnaWindow nyrnaWindow,
    required StorageRepository storage,
  }) async {
    bool autoStart = await storage.getValue('autoStart') ?? false;
    bool autoRefresh = await storage.getValue('autoRefresh') ?? true;
    bool closeToTray = await storage.getValue('closeToTray') ?? false;

    HotKey hotkey;
    String? savedHotkey = await storage.getValue('hotkey');
    if (savedHotkey != null) {
      hotkey = HotKey.fromJson(jsonDecode(savedHotkey));
    } else {
      hotkey = defaultHotkey;
    }

    bool minimizeWindows = await storage.getValue('minimizeWindows') ?? true;
    int refreshInterval = await storage.getValue('refreshInterval') ?? 5;
    bool showHiddenWindows =
        await storage.getValue('showHiddenWindows') ?? false;
    bool startHiddenInTray =
        await storage.getValue('startHiddenInTray') ?? false;

    return SettingsCubit._(
      desktopIntegration,
      getWindowInfo,
      hotkeyService,
      nyrnaWindow,
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

  Future<void> updateAutoStart(bool shouldAutostart) async {
    if (shouldAutostart) {
      await _desktopIntegration.enableAutostart();
    } else {
      await _desktopIntegration.disableAutostart();
    }

    await _storage.saveValue(key: 'autoStart', value: shouldAutostart);
    emit(state.copyWith(autoStart: shouldAutostart));
  }

  Future<void> updateAutoRefresh(bool? enabled) async {
    if (enabled == null) return;

    await _storage.saveValue(key: 'autoRefresh', value: enabled);
    appsListCubit.setAutoRefresh(
      autoRefresh: enabled,
      refreshInterval: state.refreshInterval,
    );

    emit(state.copyWith(autoRefresh: enabled));
  }

  Future<void> updateCloseToTray([bool? closeToTray]) async {
    if (closeToTray == null) return;

    await _nyrnaWindow.preventClose(closeToTray);
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
    await _hotkeyService.removeHotkey();
  }

  Future<void> resetHotkey() async {
    await _hotkeyService.updateHotkey(defaultHotkey);
    emit(state.copyWith(hotKey: defaultHotkey));
    await _storage.deleteValue('hotkey');
  }

  Future<void> updateHotkey(HotKey newHotKey) async {
    await _hotkeyService.updateHotkey(newHotKey);
    emit(state.copyWith(hotKey: newHotKey));
    await _storage.saveValue(
      key: 'hotkey',
      value: jsonEncode(newHotKey.toJson()),
    );
  }

  /// Save the current window size & position to storage.
  ///
  /// Allows the app to remember its window size for next launch.
  Future<void> saveWindowSize() async {
    final windowInfo = await _getWindowInfo();
    final rectJson = windowInfo.frame.toJson();
    await _storage.saveValue(key: 'windowSize', value: rectJson);
  }

  /// Returns if available the last window size and position.
  Future<Rect?> savedWindowSize() async {
    String? rectJson = await _storage.getValue('windowSize');
    if (rectJson == null) return null;
    final windowRect = RectConverter.fromJson(rectJson);
    return windowRect;
  }
}
