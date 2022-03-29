import 'dart:io';

import 'package:active_window/active_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart' as window;

import 'application/theme/cubit/theme_cubit.dart';
import 'apps_list/apps_list.dart';
import 'domain/arguments/argument_parser.dart';
import 'infrastructure/app_version/app_version.dart';
import 'infrastructure/logger/app_logger.dart';
import 'settings/cubit/settings_cubit.dart';
import 'settings/settings_service.dart';
import 'presentation/app_widget.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Parse command-line arguments.
  final argParser = ArgumentParser();
  argParser.parseArgs(args);

  final nativePlatform = NativePlatform();

  // If we receive the toggle argument, suspend or resume the active
  // window and then exit without showing the GUI.
  if (argParser.toggleActiveWindow) {
    await toggleActiveWindow(
      shouldLog: argParser.logToFile,
      nativePlatform: nativePlatform,
    );
    exit(0);
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsService = SettingsService(sharedPreferences);

  AppLogger().initialize();

  // Created outside runApp so it can be accessed for window settings below.
  final prefsCubit = SettingsCubit(settingsService);

  // Provides information on this app from the pubspec.yaml.
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: prefsCubit),
        BlocProvider(
          create: (context) => ThemeCubit(settingsService),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (context) => AppsListCubit(
              nativePlatform: nativePlatform,
              prefs: settingsService,
              prefsCubit: context.read<SettingsCubit>(),
              appVersion: AppVersion(packageInfo),
            ),
            lazy: false,
            child: const AppWidget(),
          );
        },
      ),
    ),
  );

  final savedWindowSize = await settingsCubit.savedWindowSize();
  if (savedWindowSize != null) {
    window.setWindowFrame(savedWindowSize);
  }
  window.setWindowVisibility(visible: true);
}
