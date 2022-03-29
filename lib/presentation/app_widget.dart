import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../apps_list/apps_list.dart';
import '../theme/theme.dart';
import 'loading_page.dart';
import '../logs/log_page.dart';
import '../settings/settings_page.dart';

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
            AppsListPage.id: (context) => const AppsListPage(),
            SettingsPage.id: (conext) => const SettingsPage(),
          },
          home: const LoadingPage(),
        );
      },
    );
  }
}
