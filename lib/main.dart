import 'dart:io';

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
import 'argument_parser/argument_parser.dart';
import 'hotkey/hotkey_service.dart';
import 'logs/logs.dart';
import 'native_platform/native_platform.dart';
import 'settings/cubit/settings_cubit.dart';
import 'storage/storage_repository.dart';
import 'system_tray/system_tray_manager.dart';
import 'theme/theme.dart';
import 'window/app_window.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Parse command-line arguments.
  final argParser = ArgumentParser() //
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
          create: (context) => AppCubit(storage),
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
