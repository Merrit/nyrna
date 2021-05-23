import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/components/window_tile.dart';
import 'package:nyrna/globals.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/settings/screens/settings_screen.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/settings/update_notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// The main screen for Nyrna.
///
/// Shows a ListView with tiles for each open window on the current desktop.
class RunningAppsScreen extends StatefulWidget {
  static const id = 'running_apps_screen';

  @override
  _RunningAppsScreenState createState() => _RunningAppsScreenState();
}

class _RunningAppsScreenState extends State<RunningAppsScreen> {
  late Nyrna nyrna;

  /// Whether or not a newer version of Nyrna is available.
  Future<bool> updateAvailable = UpdateNotifier().updateAvailable();

  static final _log = Logger('RunningAppsScreen');

  final _settings = Settings.instance;

  @override
  void initState() {
    _log.info('RunningAppsScreen initialized');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    nyrna = Provider.of<Nyrna>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 40),
            itemCount: nyrna.windows.length,
            itemBuilder: (context, index) {
              if (nyrna.windows.isEmpty) return Container();
              var keys = nyrna.windows.keys.toList();
              var window = nyrna.windows[keys[index]]!;
              return ChangeNotifierProvider<Process>(
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
      // We don't show a manual refresh button with a short auto-refresh.
      floatingActionButton:
          ((_settings.autoRefresh && _settings.refreshInterval > 5) ||
                  !_settings.autoRefresh)
              ? _floatingActionButton()
              : null,
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      // Display the current desktop index, only for Linux.
      // For Win32 this would require wrapping something like
      // GetWindowDesktopId() with FFI.
      // https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ivirtualdesktopmanager-getwindowdesktopid
      title: (Platform.isLinux)
          ? Consumer<Nyrna>(
              builder: (context, nyrna, widget) {
                return Text('Current Desktop: ${nyrna.currentDesktop}');
              },
            )
          : null,
      actions: [
        _updateIcon(),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            _log.info('User clicked settings button');
            Navigator.pushNamed(context, SettingsScreen.id);
          },
        ),
      ],
    );
  }

  /// Show an icon if a newer version of Nyrna is available.
  FutureBuilder<bool> _updateIcon() {
    return FutureBuilder<bool>(
        future: updateAvailable,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!
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

  /// Inform user about new version of Nyrna, download link, etc.
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
          title: const Text('Update available'),
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
              child: const Text('Open download page'),
            ),
            TextButton(
              onPressed: () {
                notifier.ignoreVersion(latestVersion);
                setState(() {
                  Navigator.pushReplacementNamed(context, RunningAppsScreen.id);
                });
              },
              child: const Text('Dismiss'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// FAB allows for manually refreshing the list of windows & their status.
  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () => nyrna.fetchData(),
      child: const Icon(Icons.refresh),
    );
  }
}
