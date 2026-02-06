import 'package:flutter/material.dart';

import 'styles.dart';

/// Nyrna's branded color.
const nyrnaColor = Color.fromRGBO(0, 179, 255, 1);

/// Dark app theme.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: nyrnaColor,
);

/// Light app theme.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: nyrnaColor,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadii.gentlyRounded,
      side: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
    ),
    color: const Color(0xFFF4F7FB),
    elevation: 2,
  ),
  scaffoldBackgroundColor: const Color(0xFFF2F4F9),
);

/// Perfectly black theme for use on AMOLED screens.
final ThemeData pitchBlackTheme = darkTheme.copyWith(
  appBarTheme: darkTheme.appBarTheme.copyWith(
    backgroundColor: Colors.black,
    scrolledUnderElevation: 0,
  ),
  cardTheme: darkTheme.cardTheme.copyWith(
    color: Colors.black,
    elevation: 0,
  ),
  scaffoldBackgroundColor: Colors.black,
);
