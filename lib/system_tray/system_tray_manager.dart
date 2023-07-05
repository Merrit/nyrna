import 'dart:async';
import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import '../window/app_window.dart';

class SystemTrayManager {
  final AppWindow _window;

  SystemTrayManager(this._window);

  Future<void> initialize() async {
    final String iconPath = Platform.isWindows
        ? 'assets/icons/codes.merritt.Nyrna.ico'
        : 'assets/icons/codes.merritt.Nyrna.png';

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

  /// Stream of events when the window is shown via the system tray.
  ///
  /// Allows dependent services to react to the window being shown.
  Stream<bool> get windowShownStream => _windowShownStreamController.stream;

  /// Controller for the window shown stream.
  final _windowShownStreamController = StreamController<bool>.broadcast();

  Future<void> _showWindow() async {
    await _window.show();
    _windowShownStreamController.add(true);
  }
}
