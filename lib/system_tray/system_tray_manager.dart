import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';

import '../window/nyrna_window.dart';

class SystemTrayManager {
  final SystemTray _systemTray = SystemTray();
  final NyrnaWindow _window;

  SystemTrayManager(this._window);

  Future<void> initialize() async {
    String path = Platform.isWindows
        ? 'assets/icons/nyrna.ico'
        : 'assets/icons/nyrna.png';

    final menu = Menu();
    await menu.buildFrom([
      MenuItemLable(label: 'Show', onClicked: (menuItem) => _window.show()),
      MenuItemLable(label: 'Hide', onClicked: (menuItem) => _window.hide()),
      MenuItemLable(label: 'Exit', onClicked: (menuItem) => _window.close()),
    ]);

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(
      toolTip: "Nyrna",
      iconPath: path,
    );

    await _systemTray.setContextMenu(menu);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        _systemTray.popUpContextMenu();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _window.show();
      }
    });
  }
}
