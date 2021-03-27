import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/components/input_dialog.dart';
import 'package:nyrna/globals.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/settings/components/system_integration_tiles.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen with configuration settings for Nyrna.
class SettingsScreen extends StatefulWidget {
  static const id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Check if Nyrna is running as Portable version.
  bool isPortable = false;

  Nyrna nyrna;

  /// Adds a little space between sections.
  static const double sectionPadding = 50;

  Settings settings = Settings.instance;

  @override
  void initState() {
    super.initState();
    _checkPortable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nyrna = Provider.of<Nyrna>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: SettingsList(
            contentPadding: const EdgeInsets.only(top: 40),
            darkBackgroundColor: Colors.grey[850],
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.refresh),
                    title: 'Auto Refresh',
                    subtitle: 'Update window & process info automatically',
                    switchValue: settings.autoRefresh,
                    onToggle: (value) => setState(() {
                      settings.autoRefresh = value;
                      nyrna.setRefresh();
                    }),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.timelapse),
                    title: 'Auto Refresh Interval',
                    trailing: Text('${settings.refreshInterval} seconds'),
                    enabled: settings.autoRefresh,
                    onPressed: (context) => _refreshIntervalDialog(),
                  ),
                ],
              ),
              // Only show for Nyrna Portable on Linux.
              // We use a conditional because `SettingsList` only accepts
              // `SettingsSection` items, so we can't use FutureBuilder.
              if (Platform.isLinux && isPortable)
                SettingsSection(
                  title: 'System Integration',
                  titlePadding: const EdgeInsets.only(top: sectionPadding),
                  tiles: systemIntegrationTiles(context),
                ),
              SettingsSection(
                title: 'About',
                titlePadding: const EdgeInsets.only(top: sectionPadding),
                tiles: [
                  SettingsTile(
                    leading: const Icon(Icons.info_outline),
                    title: 'Nyrna version',
                    subtitle: Globals.version,
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.launch),
                    title: 'Nyrna homepage',
                    onPressed: (context) async {
                      await launch('https://nyrna.merritt.codes');
                    },
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.launch),
                    title: 'GitHub repository',
                    onPressed: (context) async {
                      await launch('https://github.com/Merrit/nyrna');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check for `PORTABLE` file in the Nyrna directory, which should only be
  /// present for the portable build on Linux.
  Future<void> _checkPortable() async {
    final _isPortable = await settings.isPortable();
    if (_isPortable) setState(() => isPortable = _isPortable);
  }

  /// Allow user to choose reset interval.
  void _refreshIntervalDialog() async {
    final result = await showInputDialog(
      context: context,
      type: InputDialogs.onlyInt,
      title: 'Auto Refresh Interval',
      initialValue: settings.refreshInterval.toString(),
    );
    final newInterval = int.tryParse(result);
    if (newInterval != null) {
      setState(() => settings.refreshInterval = newInterval);
    }
    nyrna.setRefresh();
  }
}
