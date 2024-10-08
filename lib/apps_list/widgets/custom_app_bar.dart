import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/settings_page.dart';
import '../../app/app.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../apps_list.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsButton = IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        Navigator.pushNamed(context, SettingsPage.id);
      },
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
      title: const _SearchBar(),
      actions: [
        updateAvailableButton,
        const _WaylandWarningButton(),
        const _DebugButton(),
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

/// Search bar for filtering apps.
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Window>(
      builder: (context, controller, focusNode) {
        final Widget clearButton = BlocBuilder<AppsListCubit, AppsListState>(
          builder: (context, state) {
            if (state.windowFilter.isEmpty) {
              return const SizedBox();
            }

            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                context.read<AppsListCubit>().setWindowFilter('');
              },
            );
          },
        );

        return SizedBox(
          // Prevent the search bar from filling the entire app bar.
          height: 40,
          child: SearchBar(
            controller: controller,
            focusNode: focusNode,
            hintText: AppLocalizations.of(context)!.filterWindows,
            elevation: WidgetStateProperty.all(2),
            trailing: <Widget>[
              clearButton,
            ],
          ),
        );
      },
      emptyBuilder: (context) => const SizedBox(),
      itemBuilder: (context, suggestion) => const SizedBox(),
      onSelected: (window) {},
      suggestionsCallback: (String pattern) {
        // We call the filter method here because it benefits from the debounce
        // provided by the TypeAheadField.
        context.read<AppsListCubit>().setWindowFilter(pattern);

        /// We return an empty list because we don't want to show any
        /// suggestions, but rather let the [AppsListCubit] filter the windows.
        return [];
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
          onPressed: () => _showWarningDialog(context, state.linuxSessionMessage!),
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
          content: SelectionArea(
            child: MarkdownBody(
              data: linuxSessionMessage,
              onTapLink: (text, href, title) {
                if (href == null) {
                  log.e('Broken link: $href');
                  return;
                }

                AppCubit.instance.launchURL(href);
              },
            ),
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

/// A button that shows the debug menu.
class _DebugButton extends StatelessWidget {
  const _DebugButton();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox();

    final appsListCubit = context.read<AppsListCubit>();

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.bug_report),
        );
      },
      menuChildren: [
        MenuItemButton(
          child: const Text('Add Interaction Error'),
          onPressed: () async {
            // ignore: invalid_use_of_visible_for_testing_member
            await appsListCubit.addInteractionError(
              appsListCubit.state.windows.first,
              InteractionType.suspend,
            );
          },
        ),
      ],
    );
  }
}
