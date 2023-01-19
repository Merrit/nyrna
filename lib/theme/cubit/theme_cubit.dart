import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../storage/storage_repository.dart';
import '../theme.dart';

part 'theme_state.dart';

late ThemeCubit themeCubit;

class ThemeCubit extends Cubit<ThemeState> {
  final StorageRepository _storage;

  ThemeCubit._(
    AppTheme theme,
    this._storage,
  ) : super(ThemeState(appTheme: theme)) {
    themeCubit = this;
  }

  static Future<ThemeCubit> init(StorageRepository storage) async {
    final theme = await _getAppTheme(storage);
    return ThemeCubit._(theme, storage);
  }

  static Future<AppTheme> _getAppTheme(StorageRepository storage) async {
    String? savedTheme = await storage.getValue('appTheme');
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

  Future<void> changeTheme(AppTheme appTheme) async {
    await _storage.saveValue(key: 'appTheme', value: appTheme.toString());
    emit(state.copyWith(appTheme: appTheme));
  }
}
