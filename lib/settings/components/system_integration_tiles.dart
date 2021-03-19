import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/settings/launcher.dart';
import 'package:settings_ui/settings_ui.dart';

// In the future this can contain settings for system tray, hotkey, etc.
List<SettingsTile> systemIntegrationTiles(BuildContext context) {
  var _tiles = [];
  switch (Platform.operatingSystem) {
    case 'linux':
      _tiles = [
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

void _confirmAddToLauncher(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 150.0, vertical: 24.0),
        content: Text('This will add a menu item to the system '
            'launcher with an associated icon so launching Nyrna is easier.'
            '\n\n'
            'Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Launcher.add(context),
            child: Text('Continue'),
          ),
        ],
      );
    },
  );
}
