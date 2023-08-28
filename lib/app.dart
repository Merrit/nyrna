import 'dart:async';

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
    final appWindow = context.read<AppWindow>();

    if (settingsCubit.state.closeToTray) {
      appWindow.hide();
    } else {
      appWindow.close();
    }
  }

  Timer? timer;

  @override
  void onWindowEvent(String eventName) {
    if (eventName == 'move' || eventName == 'resize') {
      /// Set a timer between events that trigger saving the window size and
      /// location. This is required because there is no notification available
      /// for when these events *finish*, and therefore it would be triggered
      /// hundreds of times otherwise during a move event.
      timer?.cancel();
      timer = null;
      timer = Timer(
        const Duration(seconds: 5),
        () {
          context.read<AppWindow>().saveWindowSizeAndPosition();
        },
      );
    }
    super.onWindowEvent(eventName);
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
