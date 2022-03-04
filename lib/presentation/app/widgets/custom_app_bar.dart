import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/presentation/preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = Size.fromHeight(kToolbarHeight);

  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        BlocBuilder<AppCubit, AppState>(
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
          onPressed: () {
            Navigator.pushNamed(context, PreferencesPage.id);
          },
        ),
      ],
    );
  }

  /// Inform user about new version of Nyrna, download link, etc.
  Future<void> _showUpdateDialog(BuildContext context) async {
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
                    : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error launching browser'),
                        ),
                      );
              },
              child: const Text('Open download page'),
            ),
            TextButton(
              onPressed: () {
                preferencesCubit.ignoreUpdate(latestVersion);
                Navigator.pushReplacementNamed(context, AppsPage.id);
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
