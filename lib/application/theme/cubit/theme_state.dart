part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final AppTheme appTheme;

  ThemeState({
    required this.appTheme,
  });

  final Color pitchBlack = Colors.black;

  ThemeData get themeData {
    final brightness =
        (appTheme == AppTheme.light) ? Brightness.light : Brightness.dark;
    final isPitchBlack = (appTheme == AppTheme.pitchBlack);
    final appBarTheme = AppBarTheme(
      centerTitle: true,
      backgroundColor: isPitchBlack ? pitchBlack : null,
    );
    final cardColor = isPitchBlack ? pitchBlack : null;
    final scaffoldBackgroundColor = isPitchBlack ? pitchBlack : null;
    final toggleableActiveColor =
        isPitchBlack ? Colors.blue[900] : Colors.lightBlueAccent;
    return ThemeData(
      appBarTheme: appBarTheme,
      brightness: brightness,
      cardColor: cardColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      toggleableActiveColor: toggleableActiveColor,
    );
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
