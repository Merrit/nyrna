import 'package:flutter/material.dart';

class NyrnaTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.lightBlue,
    hintColor: Colors.lightBlueAccent,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.lightBlueAccent,
    ),
    toggleableActiveColor: Colors.lightBlueAccent,
  );
}
