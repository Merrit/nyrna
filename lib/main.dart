import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ArgumentParser(args);

  final sharedPreferences = await SharedPreferences.getInstance();
  final prefs = Preferences(sharedPreferences);

  AppLogger().initialize();

  final nativePlatform = NativePlatform();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PreferencesCubit(prefs),
          lazy: false,
        ),
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
}
