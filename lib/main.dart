import 'dart:io';

import 'package:args/args.dart';
import 'package:desktop_integration/desktop_integration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'active_window/active_window.dart';
import 'app.dart';
import 'app/app.dart';
import 'app_version/app_version.dart';
import 'apps_list/apps_list.dart';
import 'hotkey/hotkey_service.dart';
import 'logs/logs.dart';
import 'native_platform/native_platform.dart';
import 'settings/cubit/settings_cubit.dart';
import 'storage/storage_repository.dart';
import 'system_tray/system_tray_manager.dart';
import 'theme/theme.dart';
import 'url_launcher/url_launcher.dart';
import 'window/app_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Parse command-line arguments.
  argParser = ArgumentParser() //
    ..parseArgs(args);

  final storage = await StorageRepository.initialize(Hive);
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
    storage,
  );

  // If we receive the toggle argument, suspend or resume the active
  // window and then exit without showing the GUI.
  if (argParser.toggleActiveWindow) {
    await activeWindow.toggle();
    exit(0);
  } else {}

  final appWindow = AppWindow(storage);

  // Created outside runApp so it can be accessed for window settings below.
  final settingsCubit = await SettingsCubit.init(
    desktopIntegration: await _initDesktopIntegration(),
    hotkeyService: HotkeyService(activeWindow),
    storage: storage,
  );

  final themeCubit = await ThemeCubit.init(storage);

  // Provides information on this app from the pubspec.yaml.
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppCubit(
            storage,
            UrlLauncher(),
          ),
          lazy: false,
        ),
        BlocProvider.value(value: settingsCubit),
        BlocProvider.value(value: themeCubit),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (context) => AppsListCubit(
              nativePlatform: nativePlatform,
              prefsCubit: context.read<SettingsCubit>(),
              processRepository: processRepository,
              storage: storage,
              appVersion: AppVersion(packageInfo),
            ),
            lazy: true,
            child: const App(),
          );
        },
      ),
    ),
  );

  final systemTray = SystemTrayManager(appWindow);
  await systemTray.initialize();

  bool? startHiddenInTray = await storage.getValue('startHiddenInTray');

  if (startHiddenInTray != true) await appWindow.show();
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

/// Instantiates DesktopIntegration for DI.
Future<DesktopIntegration> _initDesktopIntegration() async {
  File? desktopFile;
  if (Platform.isLinux) {
    desktopFile = await assetToTempDir(
      'packaging/linux/codes.merritt.Nyrna.desktop',
    );
  }

  final iconFileSuffix = Platform.isWindows ? 'ico' : 'svg';
  final iconFile = await assetToTempDir(
    'assets/icons/codes.merritt.Nyrna.$iconFileSuffix',
  );

  return DesktopIntegration(
    desktopFilePath: desktopFile?.path ?? '',
    iconPath: iconFile.path,
    packageName: 'codes.merritt.nyrna',
    linkFileName: 'Nyrna',
  );
}
