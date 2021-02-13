import 'package:flutter/material.dart';
import 'package:nyrna/components/input_dialog.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  static const id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Nyrna nyrna;

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
