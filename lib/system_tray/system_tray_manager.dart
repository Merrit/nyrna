import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import '../apps_list/apps_list.dart';
import '../window/nyrna_window.dart';

class SystemTrayManager {
  final NyrnaWindow _window;

  SystemTrayManager(this._window);

  Future<void> initialize() async {
    String iconPath = Platform.isWindows
        ? 'assets/icons/nyrna.ico'
        : 'assets/icons/nyrna.png';

    await trayManager.setIcon(iconPath);

    final Menu menu = Menu(
      items: [
        MenuItem(label: 'Show', onClick: (menuItem) => _showWindow()),
        MenuItem(label: 'Hide', onClick: (menuItem) => _window.hide()),
        MenuItem(label: 'Exit', onClick: (menuItem) => _window.close()),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  Future<void> _showWindow() async {
    await _window.show();
    await appsListCubit.manualRefresh();
  }
}
