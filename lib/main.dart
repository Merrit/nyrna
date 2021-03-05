import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/arguments/parse_args.dart';
import 'package:nyrna/screens/apps_screen.dart';
import 'package:nyrna/screens/loading_screen.dart';
import 'package:nyrna/settings/screens/settings_screen.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/theme.dart';
import 'package:nyrna/window/active_window.dart';
import 'package:provider/provider.dart';

Future<void> main(List<String> args) async {
  // Parse command-line arguments.
  parseArgs(args);

  // Initialize the global settings instance in settings.dart
  // Needed early both because it runs syncronously and would block UI,
  // as well as because the toggle feature checks for a saved process.
  settings = Settings();
  await settings.initialize();

  if (Config.toggle) {
    // `-t` or `--toggle` flag detected.
    await _toggleActiveWindow();
  } else {
    // Run main GUI interface.
    runApp(MyApp());
  }
}

/// Not yet possible to run without GUI, so we just exit after toggling.
Future<void> _toggleActiveWindow() async {
  var activeWindow = ActiveWindow();
  await activeWindow.hideNyrna();
  await activeWindow.initialize();
  await activeWindow.toggle();
  exit(0);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Nyrna>(create: (_) => Nyrna()),
      ],
      child: MaterialApp(
        title: 'Nyrna',
        theme: NyrnaTheme.dark,
        routes: {
          LoadingScreen.id: (context) => LoadingScreen(),
          RunningAppsScreen.id: (context) => RunningAppsScreen(),
          SettingsScreen.id: (conext) => SettingsScreen(),
        },
        home: LoadingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
