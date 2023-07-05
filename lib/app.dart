import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../apps_list/apps_list.dart';
import '../logs/log_page.dart';
import '../theme/theme.dart';
import 'loading/loading_page.dart';
import 'settings/settings.dart';
import 'window/app_window.dart';

/// The root widget of the app.
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TrayListener, WindowListener {
  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    if (settingsCubit.state.closeToTray) {
      AppWindow.instance.hide();
      return;
    } else {
      super.onWindowClose();
    }
  }

  @override
  void onWindowRestore() {
    context.read<AppsListCubit>().manualRefresh();
    super.onWindowRestore();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
    super.onTrayIconMouseDown();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
    super.onTrayIconRightMouseDown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Nyrna',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            LoadingPage.id: (context) => const LoadingPage(),
            LogPage.id: (context) => LogPage(),
            AppsListPage.id: (context) => const AppsListPage(),
            SettingsPage.id: (conext) => SettingsPage(),
          },
          home: const LoadingPage(),
        );
      },
    );
  }
}
