part of 'theme_cubit.dart';

@freezed
sealed class ThemeState with _$ThemeState {
  const factory ThemeState({
    required AppTheme appTheme,
  }) = _ThemeState;

  /// Private constructor required for Freezed getters.
  const ThemeState._();

  ThemeData get themeData {
    switch (appTheme) {
      case AppTheme.dark:
        return darkTheme;
      case AppTheme.light:
        return lightTheme;
      case AppTheme.pitchBlack:
        return pitchBlackTheme;
    }
  }
}
