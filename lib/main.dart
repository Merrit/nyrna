import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/infrastructure/logger/app_logger.dart';
import 'package:nyrna/presentation/app_widget.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/window/active_window.dart';

import 'application/theme/cubit/theme_cubit.dart';
import 'domain/arguments/argument_parser.dart';
import 'infrastructure/logger/log_file.dart';

Future<void> main(List<String> args) async {
  // Parse command-line arguments.
  final parser = ArgumentParser(args);
  await parser.parse();

  final settings = Preferences.instance;
  await settings.initialize();

  AppLogger().initialize();

  // `-t` or `--toggle` flag detected.
  if (Config.toggle) await toggleActiveWindow();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: AppWidget(),
    ),
  );
}

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow() async {
  final _log = Logger('toggleActiveWindow');
  _log.info('toggleActiveWindow beginning');
  final activeWindow = ActiveWindow();
  await activeWindow.hideNyrna();
  await activeWindow.initialize();
  final successful = await activeWindow.toggle();
  if (!successful) {
    await activeWindow.removeSavedProcess();
    _log.warning('Failed to toggle active window. Cleared saved pid.');
  }
  _log.info('Finished toggle window, exiting.');
  if (Config.log) await LogFile.instance.write();
  // Not yet possible to run without GUI, so we just exit after toggling.
  exit(0);
}
