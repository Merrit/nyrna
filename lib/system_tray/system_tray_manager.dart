import 'dart:async';
import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import 'system_tray.dart';

class SystemTrayManager {
  SystemTrayManager();

  /// Stream of [SystemTrayEvent] events that are emitted for other services to
  /// react to.
  Stream<SystemTrayEvent> get eventStream => _eventStreamController.stream;

  /// Controller for the system tray event stream.
  final _eventStreamController = StreamController<SystemTrayEvent>.broadcast();

  Future<void> initialize() async {
    final String iconPath = Platform.isWindows
        ? 'assets/icons/codes.merritt.Nyrna.ico'
        : 'assets/icons/codes.merritt.Nyrna.png';

    await trayManager.setIcon(iconPath);

    final Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Show',
          onClick: (_) {
            _eventStreamController.add(SystemTrayEvent.windowShow);
          },
        ),
        MenuItem(
          label: 'Hide',
          onClick: (_) {
            _eventStreamController.add(SystemTrayEvent.windowHide);
          },
        ),
        MenuItem(
          label: 'Reset Window',
          onClick: (_) {
            _eventStreamController.add(SystemTrayEvent.windowReset);
          },
        ),
        MenuItem(
          label: 'Exit',
          onClick: (_) {
            _eventStreamController.add(SystemTrayEvent.exit);
          },
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }
}
