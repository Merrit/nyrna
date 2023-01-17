import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/theme/theme.dart';

import '../../settings/cubit/settings_cubit_test.dart';

late ThemeCubit cubit;
ThemeState get state => cubit.state;

void main() {
  final settingsService = MockSettingsService();

  group('ThemeCubit:', () {
    setUp(() {
      when(() => settingsService.getString(any())).thenReturn(null);
      when(() => settingsService.setString(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      cubit = ThemeCubit(settingsService);
    });

    test('global instance is available', () {
      expect(themeCubit, isA<ThemeCubit>());
    });

    test('default theme is dark', () {
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved light theme preference loads light theme', () {
      when(() => settingsService.getString('appTheme'))
          .thenReturn('AppTheme.light');
      cubit = ThemeCubit(settingsService);
      expect(state.appTheme, AppTheme.light);
    });

    test('saved dark theme preference loads dark theme', () {
      when(() => settingsService.getString('appTheme'))
          .thenReturn('AppTheme.dark');
      cubit = ThemeCubit(settingsService);
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved pitch black theme preference loads pitch black theme', () {
      when(() => settingsService.getString('appTheme'))
          .thenReturn('AppTheme.pitchBlack');
      cubit = ThemeCubit(settingsService);
      expect(state.appTheme, AppTheme.pitchBlack);
    });

    test('changing theme works', () {
      // Default
      expect(state.appTheme, AppTheme.dark);
      // Light
      cubit.changeTheme(AppTheme.light);
      expect(state.appTheme, AppTheme.light);
      verify(() => settingsService.setString(
            key: 'appTheme',
            value: 'AppTheme.light',
          )).called(1);
      // Dark
      cubit.changeTheme(AppTheme.dark);
      expect(state.appTheme, AppTheme.dark);
      verify(() => settingsService.setString(
            key: 'appTheme',
            value: 'AppTheme.dark',
          )).called(1);
      // Pitch Black
      cubit.changeTheme(AppTheme.pitchBlack);
      expect(state.appTheme, AppTheme.pitchBlack);
      verify(() => settingsService.setString(
            key: 'appTheme',
            value: 'AppTheme.pitchBlack',
          )).called(1);
    });
  });
}
