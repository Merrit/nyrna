part of 'theme_cubit.dart';

@immutable
class ThemeState extends Equatable {
  final AppTheme appTheme;

  const ThemeState({
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
    final tooltipThemeData = TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.grey[700]!.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 50),
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
    return ThemeData(
      appBarTheme: appBarTheme,
      brightness: brightness,
      cardColor: cardColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      tooltipTheme: tooltipThemeData,
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
