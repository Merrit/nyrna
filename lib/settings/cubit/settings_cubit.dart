import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:nyrna/hotkey/hotkey_service.dart';
import 'package:window_size/window_size.dart' as window;

import '../../apps_list/apps_list.dart';
import '../../core/core.dart';
import '../../theme/styles.dart';
import '../hotkey.dart';
import '../icon_manager.dart';
import '../settings_service.dart';

part 'settings_state.dart';

late SettingsCubit settingsCubit;

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _prefs;
  final HotkeyService _hotkeyService;

  SettingsCubit._(
    this._prefs,
    this._hotkeyService, {
    required SettingsState initialState,
  }) : super(initialState) {
    settingsCubit = this;
    _hotkeyService.updateHotkey(state.hotKey);
  }

  factory SettingsCubit({
    required SettingsService prefs,
    required HotkeyService hotkeyService,
  }) {
    HotKey? hotkey;
    final String? savedHotkey = prefs.getString('hotkey');
    if (savedHotkey != null) {
      hotkey = HotKey.fromJson(jsonDecode(savedHotkey));
    } else {
      hotkey = defaultHotkey;
    }

    return SettingsCubit._(
      prefs,
      hotkeyService,
      initialState: SettingsState(
        autoStartHotkey: prefs.getBool('autoStartHotkey') ?? false,
        autoRefresh: _checkAutoRefresh(prefs),
        closeToTray: prefs.getBool('closeToTray') ?? false,
        hotKey: hotkey,
        refreshInterval: prefs.getInt('refreshInterval') ?? 5,
        showHiddenWindows: prefs.getBool('showHiddenWindows') ?? false,
        trayIconColor: Color(
          prefs.getInt('trayIconColor') ?? AppColors.defaultIconColor,
        ),
      ),
    );
  }

  static bool _checkAutoRefresh(SettingsService prefs) {
    return prefs.getBool('autoRefresh') ?? true;
  }

  /// If user wishes to ignore this update, save to SharedPreferences.
  Future<void> ignoreUpdate(String version) async {
    await _prefs.setString(key: 'ignoredUpdate', value: version);
  }

  Future<void> setRefreshInterval(int interval) async {
    if (interval > 0) {
      await _prefs.setInt(key: 'refreshInterval', value: interval);
      emit(state.copyWith(refreshInterval: interval));
    }
  }

  Future<bool> updateAutoStartHotkey(bool value) async {
    final successful = await Hotkey().autoStart(value);
    if (!successful) return false;
    await _prefs.setBool(key: 'autoStartHotkey', value: value);
    emit(state.copyWith(autoStartHotkey: value));
    return true;
  }

  Future<void> updateAutoRefresh([bool? autoEnabled]) async {
    if (autoEnabled != null) {
      await _prefs.setBool(key: 'autoRefresh', value: autoEnabled);
      appsListCubit.setAutoRefresh(
        autoRefresh: autoEnabled,
        refreshInterval: state.refreshInterval,
      );
      emit(state.copyWith(autoRefresh: autoEnabled));
    }
  }

  Future<void> updateCloseToTray([bool? closeToTray]) async {
    if (closeToTray == null) return;

    await _prefs.setBool(key: 'closeToTray', value: closeToTray);
    emit(state.copyWith(closeToTray: closeToTray));
  }

  Future<Uint8List> iconBytes() async {
    final iconManager = IconManager();
    final iconBytes = await iconManager.iconBytes();
    return iconBytes;
  }

  Future<void> updateIconColor(Color newColor) async {
    final successful = await IconManager().updateIconColor(newColor);
    if (successful) {
      await _prefs.setInt(key: 'trayIconColor', value: newColor.value);
      emit(state.copyWith(trayIconColor: newColor));
    }
  }

  Future<void> updateShowHiddenWindows(bool value) async {
    await _prefs.setBool(key: 'showHiddenWindows', value: value);
    emit(state.copyWith(showHiddenWindows: value));
  }

  Future<void> resetHotkey() async {
    await _hotkeyService.updateHotkey(defaultHotkey);
    emit(state.copyWith(hotKey: defaultHotkey));
    await _prefs.remove('hotkey');
  }

  Future<void> updateHotkey(HotKey newHotKey) async {
    await _hotkeyService.updateHotkey(newHotKey);
    emit(state.copyWith(hotKey: newHotKey));
    await _prefs.setString(
      key: 'hotkey',
      value: jsonEncode(newHotKey.toJson()),
    );
  }

  /// Save the current window size & position to storage.
  ///
  /// Allows the app to remember its window size for next launch.
  Future<void> saveWindowSize() async {
    final windowInfo = await window.getWindowInfo();
    final rectJson = windowInfo.frame.toJson();
    await _prefs.setString(key: 'windowSize', value: rectJson);
  }

  /// Returns if available the last window size and position.
  Future<Rect?> savedWindowSize() async {
    final rectJson = _prefs.getString('windowSize');
    if (rectJson == null) return null;
    final windowRect = RectConverter.fromJson(rectJson);
    return windowRect;
  }
}
