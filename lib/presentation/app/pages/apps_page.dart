import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/application/theme/theme.dart';
import 'package:nyrna/presentation/app/widgets/window_tile.dart';
import 'package:nyrna/presentation/preferences/pages/preferences_page.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// The main screen for Nyrna.
///
/// Shows a ListView with tiles for each open window on the current desktop.
class AppsPage extends StatefulWidget {
  static const id = 'running_apps_screen';

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  static final _log = Logger('RunningAppsScreen');

  @override
  void initState() {
    _log.info('RunningAppsScreen initialized');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 40),
                itemCount: state.windows.length,
                itemBuilder: (context, index) {
                  if (state.windows.isEmpty) return Container();
                  var keys = state.windows.keys.toList();
                  var window = state.windows[keys[index]]!;
                  return ChangeNotifierProvider<Process>(
                    key: ValueKey('${window.pid}${window.title}'),
                    create: (context) => Process(window.pid),
                    child: WindowTile(
                      key: ValueKey('${window.pid}${window.title}'),
                      window: window,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      // We don't show a manual refresh button with a short auto-refresh.
      floatingActionButton: _FloatingActionButton(),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      // Display the current desktop index, only for Linux.
      // For Win32 this would require wrapping something like
      // GetWindowDesktopId() with FFI.
      // https://docs.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ivirtualdesktopmanager-getwindowdesktopid
      title: (Platform.isLinux)
          ? BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return Text('Current Desktop: ${state.currentDesktop}');
              },
            )
          : null,
      actions: [
        _updateIcon(),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            _log.info('User clicked settings button');
            Navigator.pushNamed(context, PreferencesPage.id);
          },
        ),
      ],
    );
  }

  /// Show an icon if a newer version of Nyrna is available.
  Widget _updateIcon() {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return state.updateAvailable
            ? IconButton(
                icon: Icon(
                  Icons.notifications_active,
                  color: Colors.pink[400],
                ),
                onPressed: () => _showUpdateDialog(),
              )
            : Container();
      },
    );
  }

  /// Inform user about new version of Nyrna, download link, etc.
  Future<void> _showUpdateDialog() async {
    final state = appCubit.state;
    final currentVersion = state.runningVersion;
    final latestVersion = state.updateVersion;
    const url = 'https://nyrna.merritt.codes/download';
    var _message = 'An update for Nyrna is available!\n\n'
        'Current version: $currentVersion\n'
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
                preferencesCubit.ignoreUpdate(latestVersion);
                setState(() {
                  Navigator.pushReplacementNamed(context, AppsPage.id);
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
}

class _FloatingActionButton extends StatelessWidget {
  _FloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        final autoRefresh = state.autoRefresh;
        final refreshIntervalSufficient = (state.refreshInterval > 5);
        final showFloatingActionButton =
            ((autoRefresh && refreshIntervalSufficient) || !autoRefresh);

        return showFloatingActionButton
            ? BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  return FloatingActionButton(
                    backgroundColor: (state.appTheme == AppTheme.pitchBlack)
                        ? Colors.black
                        : null,
                    onPressed: () => appCubit.fetchData(),
                    child: const Icon(Icons.refresh),
                  );
                },
              )
            : Container();
      },
    );
  }
}
