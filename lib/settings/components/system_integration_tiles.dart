import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/settings/launcher.dart';
import 'package:settings_ui/settings_ui.dart';

// In the future this can contain settings for system tray, hotkey, etc.
List<SettingsTile> systemIntegrationTiles(BuildContext context) {
  var _tiles = <SettingsTile>[];
  switch (Platform.operatingSystem) {
    case 'linux':
      _tiles = <SettingsTile>[
        SettingsTile(
          leading: Icon(Icons.add_circle_outline),
          title: 'Add Nyrna to launcher',
          onPressed: (context) => _confirmAddToLauncher(context),
        ),
      ];
      break;
    case 'windows':
      // _tiles = []
      break;
    default:
      break;
  }
  return _tiles;
}

/// Confirm with the user before adding .desktop and icon files.
void _confirmAddToLauncher(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 150.0,
          vertical: 24.0,
        ),
        content: const Text('This will add a menu item to the system '
            'launcher with an associated icon so launching Nyrna is easier.'
            '\n\n'
            'Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Launcher.add(context),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
}
