import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nyrna/settings/settings_service.dart';

import '../theme.dart';

part 'theme_state.dart';

late ThemeCubit themeCubit;

class ThemeCubit extends Cubit<ThemeState> {
  final SettingsService _prefs;

  ThemeCubit(SettingsService prefs)
      : _prefs = prefs,
        super(
          ThemeState(appTheme: _getAppTheme(prefs)),
        ) {
    themeCubit = this;
  }

  static AppTheme _getAppTheme(SettingsService prefs) {
    final savedTheme = prefs.getString('appTheme');
    switch (savedTheme) {
      case null:
        return AppTheme.dark;
      case 'AppTheme.light':
        return AppTheme.light;
      case 'AppTheme.dark':
        return AppTheme.dark;
      case 'AppTheme.pitchBlack':
        return AppTheme.pitchBlack;
      default:
        return AppTheme.dark;
    }
  }

  void changeTheme(AppTheme appTheme) {
    _prefs.setString(key: 'appTheme', value: appTheme.toString());
    emit(state.copyWith(appTheme: appTheme));
  }
}
