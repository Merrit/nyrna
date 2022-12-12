import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'window/nyrna_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Parse command-line arguments.
  final argParser = ArgumentParser();
  argParser.parseArgs(args);

  final storageRepository = await StorageRepository.initialize(Hive);
  final nativePlatform = NativePlatform();
  await LoggingManager.initialize(verbose: argParser.verbose);

  // If we receive the toggle argument, suspend or resume the active
  // window and then exit without showing the GUI.
  if (argParser.toggleActiveWindow) {
    await toggleActiveWindow(nativePlatform, storageRepository);
    exit(0);
  } else {}

  // Handle platform errors not caught by Flutter.
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('Uncaught platform error', error, stack);
    return true;
  };

  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsService = SettingsService(sharedPreferences);

  final nyrnaWindow = NyrnaWindow();

  final appCubit = AppCubit(
    canLaunchUrl,
    launchUrl,
  );

  // Created outside runApp so it can be accessed for window settings below.
  final _settingsCubit = SettingsCubit(
    assetToTempDir: assetToTempDir,
    getWindowInfo: window.getWindowInfo,
    prefs: settingsService,
    hotkeyService: HotkeyService(nativePlatform, storageRepository),
    nyrnaWindow: nyrnaWindow,
  );

  // Provides information on this app from the pubspec.yaml.
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appCubit),
        BlocProvider.value(value: _settingsCubit),
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
              processRepository: ProcessRepository.init(),
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

/// Parse command-line arguments.
class ArgumentParser {
  bool toggleActiveWindow = false;
  bool verbose = false;

  final _parser = ArgParser(usageLineLength: 80);

  /// Parse received arguments.
  void parseArgs(List<String> args) {
    _parser
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

    final _helpText = _helpTextGreeting + _parser.usage + '\n\n';

    try {
      final result = _parser.parse(args);
      if (result.rest.isNotEmpty) {
        stdout.writeln(_helpText);
        exit(0);
      }
    } on ArgParserException {
      stdout.writeln(_helpText);
      exit(0);
    }
  }
}
