import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nyrna/application/theme/enums/app_theme.dart';
import 'package:nyrna/settings/settings.dart';

part 'theme_state.dart';

late ThemeCubit themeCubit;

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(appTheme: Settings.instance.appTheme)) {
    themeCubit = this;
  }

  void changeTheme(AppTheme appTheme) {
    Settings.instance.appTheme = appTheme;
    emit(state.copyWith(appTheme: appTheme));
  }
}
