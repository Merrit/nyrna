import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/presentation/logs/pages/log_page.dart';
import 'package:nyrna/presentation/app_widget.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/window/active_window.dart';

import 'application/theme/cubit/theme_cubit.dart';
import 'domain/arguments/argument_parser.dart';
import 'infrastructure/logger/log_file.dart';

Future<void> main(List<String> args) async {
  // Parse command-line arguments.
  final parser = ArgumentParser(args);
  await parser.parse();

  await initSettings();

  initLogger();

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

/// Initialize the singleton Settings instance in settings.dart
///
/// Needed early both because it runs syncronously and would block UI,
/// as well as because the toggle feature checks for a saved process.
Future<void> initSettings() async {
  final settings = Settings.instance;
  await settings.initialize();
}

/// Print log messages & add them to a Queue so they can be referenced, for
/// example from the [LogPage].
void initLogger() {
  final logQueue = LogFile.logs;
  Logger.root.onRecord.listen((record) {
    var msg = '${record.level.name}: ${record.time}: '
        '${record.loggerName}: ${record.message}';
    if (record.error != null) msg += '\nError: ${record.error}';
    print(msg);
    logQueue.addLast(record);
    // In case the log grows too crazy, prune for sanity.
    while (logQueue.length > 100) {
      logQueue.removeFirst();
    }
  });
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
