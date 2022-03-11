import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/theme/theme.dart';
import 'package:nyrna/presentation/logs/pages/log_page.dart';
import 'package:nyrna/presentation/loading_page.dart';
import 'package:nyrna/presentation/preferences/pages/preferences_page.dart';

import 'app/app.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Nyrna',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          routes: {
            LoadingPage.id: (context) => const LoadingPage(),
            LogPage.id: (context) => const LogPage(),
            AppsPage.id: (context) => const AppsPage(),
            PreferencesPage.id: (conext) => const PreferencesPage(),
          },
          home: const LoadingPage(),
        );
      },
    );
  }
}
