import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/settings_page.dart';
import '../../app/app.dart';
import '../../logs/logs.dart';
import '../apps_list.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsButton = IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => Navigator.pushNamed(context, SettingsPage.id),
    );

    final updateAvailableButton = BlocBuilder<AppsListCubit, AppsListState>(
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
    );

    return AppBar(
      actions: [
        updateAvailableButton,
        const _WaylandWarningButton(),
        settingsButton,
      ],
    );
  }

  /// Inform user about new version of Nyrna, download link, etc.
  Future<void> _showUpdateDialog(BuildContext context) async {
    final appsListCubit = context.read<AppsListCubit>();
    final state = appsListCubit.state;
    final currentVersion = state.runningVersion;
    final latestVersion = state.updateVersion;
    const url = 'https://nyrna.merritt.codes/download';
    final message = 'An update for Nyrna is available!\n\n'
        'Current version: $currentVersion\n'
        'Latest version: $latestVersion';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update available'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final launched = await AppCubit.instance.launchURL(url);

                if (!launched) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Error launching browser'),
                    ),
                  );
                }
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

/// Shows a warning button if running on Wayland.
class _WaylandWarningButton extends StatelessWidget {
  const _WaylandWarningButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state.linuxSessionMessage == null) {
          return const SizedBox();
        }

        return IconButton(
          icon: const Icon(Icons.warning),
          onPressed: () =>
              _showWarningDialog(context, state.linuxSessionMessage!),
        );
      },
    );
  }

  Future<void> _showWarningDialog(
    BuildContext context,
    String linuxSessionMessage,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: MarkdownBody(
            data: linuxSessionMessage,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href == null) {
                log.e('Broken link: $href');
                return;
              }

              AppCubit.instance.launchURL(href);
            },
          ),
          actions: [
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
