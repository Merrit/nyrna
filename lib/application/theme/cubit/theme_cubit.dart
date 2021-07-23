import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nyrna/application/theme/enums/app_theme.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';

part 'theme_state.dart';

late ThemeCubit themeCubit;

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(appTheme: Preferences.instance.appTheme)) {
    themeCubit = this;
  }

  void changeTheme(AppTheme appTheme) {
    Preferences.instance.appTheme = appTheme;
    emit(state.copyWith(appTheme: appTheme));
  }
}
