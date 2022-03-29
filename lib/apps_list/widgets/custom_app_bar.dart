import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/settings_page.dart';
import '../apps_list.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        BlocBuilder<AppsListCubit, AppsListState>(
          builder: (context, state) {
            return state.updateAvailable
                ? IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: Colors.pink[400],
                    ),
                    onPressed: () => _showUpdateDialog(context),
                  )
                : Container();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, SettingsPage.id),
        ),
      ],
    );
  }

  /// Inform user about new version of Nyrna, download link, etc.
  Future<void> _showUpdateDialog(BuildContext context) async {
    final state = appsListCubit.state;
    final currentVersion = state.runningVersion;
    final latestVersion = state.updateVersion;
    const url = 'https://nyrna.merritt.codes/download';
    final _message = 'An update for Nyrna is available!\n\n'
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
                    : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error launching browser'),
                        ),
                      );
              },
              child: const Text('Open download page'),
            ),
            TextButton(
              onPressed: () {
                settingsCubit.ignoreUpdate(latestVersion);
                Navigator.pushReplacementNamed(context, AppsListPage.id);
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
