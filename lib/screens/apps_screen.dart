import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/components/window_tile.dart';
import 'package:nyrna/globals.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/settings/screens/settings_screen.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/settings/update_notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RunningAppsScreen extends StatefulWidget {
  static const id = 'running_apps_screen';

  @override
  _RunningAppsScreenState createState() => _RunningAppsScreenState();
}

class _RunningAppsScreenState extends State<RunningAppsScreen> {
  Nyrna nyrna;
  Future<bool> updateAvailable = UpdateNotifier().updateAvailable;

  @override
  void didChangeDependencies() {
    nyrna = Provider.of<Nyrna>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Platform.isLinux)
            ? Consumer<Nyrna>(
                builder: (context, nyrna, widget) {
                  return Text('Current Desktop: ${nyrna.currentDesktop}');
                },
              )
            : null,
        centerTitle: true,
        actions: [
          _updateIcon(),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.id),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 40),
            itemCount: nyrna.windows.length,
            itemBuilder: (context, index) {
              if (nyrna.windows.isEmpty) return Container();
              var keys = nyrna.windows.keys.toList();
              var window = nyrna.windows[keys[index]];
              return ChangeNotifierProvider(
                key: ValueKey('${window.pid}${window.title}'),
                create: (context) => Process(window.pid),
                child: WindowTile(
                  key: ValueKey('${window.pid}${window.title}'),
                  window: window,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton:
          ((settings.autoRefresh && settings.refreshInterval > 5) ||
                  !settings.autoRefresh)
              ? _floatingActionButton()
              : null,
    );
  }

  FutureBuilder<bool> _updateIcon() {
    return FutureBuilder<bool>(
        future: updateAvailable,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (snapshot.data)
                ? IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: Colors.pink[400],
                    ),
                    onPressed: () => _showUpdateDialog(),
                  )
                : Container();
          }
          return Container();
        });
  }

  Future<void> _showUpdateDialog() async {
    final notifier = UpdateNotifier();
    final latestVersion = await notifier.latestVersion();
    const url = 'https://nyrna.merritt.codes/download';
    var _message = 'An update for Nyrna is available!\n\n'
        'Current version: ${Globals.version}\n'
        'Latest version: $latestVersion';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update available'),
          content: Text(_message),
          actions: [
            TextButton(
              onPressed: () async {
                await canLaunch(url)
                    ? launch(url)
                    : setState(() {
                        _message = 'Error launching browser.';
                      });
              },
              child: Text('Open download page'),
            ),
            TextButton(
              onPressed: () {
                notifier.ignoreVersion(latestVersion);
                setState(() {
                  Navigator.pushReplacementNamed(context, RunningAppsScreen.id);
                });
              },
              child: Text('Dismiss'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () => nyrna.fetchData(),
      child: Icon(Icons.refresh),
    );
  }
}
