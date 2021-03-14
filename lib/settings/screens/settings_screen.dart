import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/components/input_dialog.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/settings/components/system_integration_tiles.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  static const id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Nyrna nyrna;

  /// Check for `PORTABLE` file in the Nyrna directory, which should only be
  /// present for the portable build on Linux.
  final portableFile = File('PORTABLE');
  bool isPortable = false;

  /// Adds a little space between sections.
  static const double sectionPadding = 50;

  @override
  void initState() {
    super.initState();
    _checkPortable();
  }

  /// Check if Nyrna is running as Portable version.
  Future<void> _checkPortable() async {
    final _isPortable = await portableFile.exists();
    if (_isPortable) {
      setState(() => isPortable = _isPortable);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nyrna = Provider.of<Nyrna>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: SettingsList(
            contentPadding: EdgeInsets.only(top: 40),
            darkBackgroundColor: Colors.grey[850],
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    leading: Icon(Icons.refresh),
                    title: 'Auto Refresh',
                    subtitle: 'Update window & process info automatically',
                    switchValue: settings.autoRefresh,
                    onToggle: (value) => setState(() {
                      settings.autoRefresh = value;
                      nyrna.setRefresh();
                    }),
                  ),
                  SettingsTile(
                    leading: Icon(Icons.timelapse),
                    title: 'Auto Refresh Interval',
                    trailing: Text('${settings.refreshInterval} seconds'),
                    enabled: settings.autoRefresh,
                    onPressed: (context) => _refreshInterval(),
                  ),
                ],
              ),
              // Only show for Nyrna Portable on Linux.
              if (Platform.isLinux && isPortable)
                SettingsSection(
                  title: 'System Integration',
                  titlePadding: EdgeInsets.only(top: sectionPadding),
                  tiles: systemIntegrationTiles(context),
                ),
              SettingsSection(
                title: 'About',
                titlePadding: EdgeInsets.only(top: sectionPadding),
                tiles: [
                  SettingsTile(
                    leading: Icon(Icons.info_outline),
                    title: 'Nyrna version',
                    subtitle: '2.0-alpha.1', // TODO: Automate this.
                  ),
                  SettingsTile(
                    leading: Icon(Icons.launch),
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

  _refreshInterval() async {
    var result = await showInputDialog(
      context: context,
      type: InputDialogs.onlyInt,
      title: 'Auto Refresh Interval',
      initialValue: settings.refreshInterval.toString(),
    );
    var newInterval = int.tryParse(result);
    if (newInterval != null) {
      setState(() => settings.refreshInterval = newInterval);
    }
    nyrna.setRefresh();
  }
}
