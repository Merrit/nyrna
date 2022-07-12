import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../apps_list/apps_list.dart';
import '../logs/log_page.dart';
import '../theme/theme.dart';
import 'loading/loading_page.dart';
import 'settings/settings.dart';
import 'window/nyrna_window.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    /// Only working on Windows for some reason.
    /// Linux will use `flutter_window_close` instead.
    if (settingsCubit.state.closeToTray) {
      NyrnaWindow().hide();
      return;
    } else {
      super.onWindowClose();
    }
  }

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
