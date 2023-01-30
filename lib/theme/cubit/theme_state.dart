part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final AppTheme appTheme;

  const ThemeState({
    required this.appTheme,
  });

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

  ThemeState copyWith({
    AppTheme? appTheme,
  }) {
    return ThemeState(
      appTheme: appTheme ?? this.appTheme,
    );
  }

  @override
  List<Object> get props => [appTheme];
}
