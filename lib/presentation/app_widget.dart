import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/theme/theme.dart';
import 'package:nyrna/logger/log_screen.dart';
import 'package:nyrna/screens/apps_screen.dart';
import 'package:nyrna/screens/loading_screen.dart';
import 'package:nyrna/settings/screens/settings_screen.dart';
import 'package:provider/provider.dart';

import '../nyrna.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Nyrna>(create: (_) => Nyrna()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Nyrna',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            routes: {
              LoadingScreen.id: (context) => LoadingScreen(),
              LogScreen.id: (context) => LogScreen(),
              RunningAppsScreen.id: (context) => RunningAppsScreen(),
              SettingsScreen.id: (conext) => SettingsScreen(),
            },
            home: LoadingScreen(),
          );
        },
      ),
    );
  }
}
