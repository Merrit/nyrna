import 'dart:io';

import 'package:active_window/active_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart' as window;

import 'application/app/app.dart';
import 'application/preferences/cubit/preferences_cubit.dart';
import 'application/theme/cubit/theme_cubit.dart';
import 'domain/arguments/argument_parser.dart';
import 'infrastructure/logger/app_logger.dart';
import 'infrastructure/preferences/preferences.dart';
import 'infrastructure/versions/versions.dart';
import 'presentation/app_widget.dart';

Future<void> main(List<String> args) async {
  // Parse command-line arguments.
  final argParser = ArgumentParser();
  argParser.parseArgs(args);

  // If we receive the toggle argument, suspend or resume the active
  // window and then exit without showing the GUI.
  if (argParser.toggleActiveWindow) {
    await toggleActiveWindow(logToFile: argParser.logToFile);
    exit(0);
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final prefs = Preferences(sharedPreferences);

  AppLogger().initialize();

  final nativePlatform = NativePlatform();

  // Created outside runApp so it can be accessed for window settings below.
  final prefsCubit = PreferencesCubit(prefs);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: prefsCubit),
        BlocProvider(
          create: (context) => ThemeCubit(prefs),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (context) => AppCubit(
              nativePlatform: nativePlatform,
              prefs: prefs,
              prefsCubit: context.read<PreferencesCubit>(),
              versionRepository: Versions(),
            ),
            lazy: false,
            child: AppWidget(),
          );
        },
      ),
    ),
  );

  final savedWindowSize = await preferencesCubit.savedWindowSize();
  if (savedWindowSize != null) {
    window.setWindowFrame(savedWindowSize);
  }
  window.setWindowVisibility(visible: true);
}
