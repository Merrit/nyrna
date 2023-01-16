import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window;

import 'active_window/active_window.dart';
import 'app.dart';
import 'app/app.dart';
import 'app_version/app_version.dart';
import 'apps_list/apps_list.dart';
import 'hotkey/hotkey_service.dart';
import 'logs/logs.dart';
import 'native_platform/native_platform.dart';
import 'settings/cubit/settings_cubit.dart';
import 'settings/settings_service.dart';
import 'storage/storage_repository.dart';
import 'system_tray/system_tray_manager.dart';
import 'theme/theme.dart';
import 'url_launcher/url_launcher.dart';
import 'window/nyrna_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Parse command-line arguments.
  argParser = ArgumentParser() //
    ..parseArgs(args);

  final storageRepository = await StorageRepository.initialize(Hive);
  final nativePlatform = NativePlatform();
  await LoggingManager.initialize(verbose: argParser.verbose);

  // Handle platform errors not caught by Flutter.
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('Uncaught platform error', error, stack);
    return true;
  };

  final processRepository = ProcessRepository.init();

  final activeWindow = ActiveWindow(
    nativePlatform,
    processRepository,
    storageRepository,
  );

  // If we receive the toggle argument, suspend or resume the active
  // window and then exit without showing the GUI.
  if (argParser.toggleActiveWindow) {
    await activeWindow.toggle();
    exit(0);
  } else {}

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsService = SettingsService(sharedPreferences);

  final nyrnaWindow = NyrnaWindow();

  // Created outside runApp so it can be accessed for window settings below.
  final settingsCubit = await SettingsCubit.init(
    assetToTempDir: assetToTempDir,
    getWindowInfo: window.getWindowInfo,
    prefs: settingsService,
    hotkeyService: HotkeyService(activeWindow),
    nyrnaWindow: nyrnaWindow,
    storageRepository: storageRepository,
  );

  // Provides information on this app from the pubspec.yaml.
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(
            storageRepository,
            UrlLauncher(),
          ),
          lazy: false,
        ),
        BlocProvider.value(value: settingsCubit),
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
              processRepository: processRepository,
              appVersion: AppVersion(packageInfo),
            ),
            lazy: false,
            child: const App(),
          );
        },
      ),
    ),
  );

  final systemTray = SystemTrayManager(nyrnaWindow);
  await systemTray.initialize();

  final savedWindowSize = await settingsCubit.savedWindowSize();
  if (savedWindowSize != null) {
    window.setWindowFrame(savedWindowSize);
  }

  bool visible = true;
  if (settingsService.getBool('startHiddenInTray') == true) {
    visible = false;
  }

  window.setWindowVisibility(visible: visible);
}

/// Message to be displayed if Nyrna is called with an unknown argument.
const _helpTextGreeting = '''
Nyrna - Suspend games and applications.


Run Nyrna without any arguments to launch the GUI.

Supported arguments:

''';

late ArgumentParser argParser;

/// Parse command-line arguments.
class ArgumentParser {
  bool? minimize;
  bool toggleActiveWindow = false;
  bool verbose = false;

  final _parser = ArgParser(usageLineLength: 80);

  /// Parse received arguments.
  void parseArgs(List<String> args) {
    _parser
      ..addFlag(
        'minimize',
        defaultsTo: true,
        callback: (bool value) {
          /// We only want to register when the user calls the negated version of
          /// this flag: `--no-minimize`. Otherwise the [minimize] value will be
          /// null and the UI-set preference can be checked.
          if (value == true) {
            return;
          } else {
            minimize = false;
          }
        },
        help: '''
Used with the `toggle` flag, `no-minimize` instructs Nyrna not to automatically minimize / restore the active window - it will be suspended / resumed only.''',
      )
      ..addFlag(
        'toggle',
        abbr: 't',
        negatable: false,
        callback: (bool value) => toggleActiveWindow = value,
        help: 'Toggle the suspend / resume state for the active window. \n'
            '❗Please note this will immediately suspend the active window, and '
            'is intended to be used with a hotkey - be sure not to run this '
            'from a terminal and accidentally suspend your terminal! ❗',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        callback: (bool value) => verbose = value,
        help: 'Output verbose logs for troubleshooting and debugging.',
      );

    final helpText = '$_helpTextGreeting${_parser.usage}\n\n';

    try {
      final result = _parser.parse(args);
      if (result.rest.isNotEmpty) {
        stdout.writeln(helpText);
        exit(0);
      }
    } on ArgParserException {
      stdout.writeln(helpText);
      exit(0);
    }
  }
}
