import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../application/theme/theme.dart';
import '../settings/cubit/settings_cubit.dart';
import 'apps_list.dart';

/// The main screen for Nyrna.
///
/// Shows a ListView with tiles for each open window on the current desktop.
class AppsListPage extends StatefulWidget {
  static const id = 'running_apps_screen';

  const AppsListPage({Key? key}) : super(key: key);

  @override
  State<AppsListPage> createState() => _AppsListPageState();
}

class _AppsListPageState extends State<AppsListPage>
    with WidgetsBindingObserver {
  /// Tracks the current window size.
  ///
  /// Updated in [initState], [dispose], and [didChangeMetrics] so that
  /// we can save the window size when the user resizes the window.
  late Size _appWindowSize;

  @override
  void initState() {
    super.initState();
    _appWindowSize = WidgetsBinding.instance.window.physicalSize;
    // Listen for changes to the application's window size.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final updatedWindowSize = WidgetsBinding.instance.window.physicalSize;
    if (_appWindowSize != updatedWindowSize) {
      _appWindowSize = updatedWindowSize;
      settingsCubit.saveWindowSize();
    }
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: BlocConsumer<AppsListCubit, AppsListState>(
        listener: (context, state) {
          if (state.interactionError == null) return;

          showDialog(
              context: context,
              builder: (context) {
                return InteractionErrorDialog(
                  interactionError: state.interactionError!,
                );
              });
        },
        builder: (context, state) {
          return Stack(
            children: [
              Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    if (!state.loading && state.windows.isEmpty) ...[
                      const _NoWindowsCard(),
                    ] else ...[
                      ...state.windows
                          .map(
                            (window) => WindowTile(
                              key: ValueKey(window),
                              window: window,
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),
              const _ProgressOverlay(),
            ],
          );
        },
      ),
      // We don't show a manual refresh button with a short auto-refresh.
      floatingActionButton: const _FloatingActionButton(),
    );
  }
}

/// A dialog to inform the user that interacting with a process has failed.
class InteractionErrorDialog extends StatelessWidget {
  final InteractionError interactionError;

  const InteractionErrorDialog({
    Key? key,
    required this.interactionError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final executable = interactionError.window.process.executable;

    return AlertDialog(
      title: const Text('Interaction Error'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MarkdownBody(
            data: 'There was an issue interacting with *$executable*.'
                '\n\n'
                'This often happens with games that use Easy Anti-Cheat.'
                '\n\n'
                'You can check if your game uses this by searching for it at '
                '[pcgamingwiki.com](https://www.pcgamingwiki.com) and checking '
                'if the "Middleware" section lists Easy Anti-Cheat.'
                '\n\n'
                'Due to the restricted and obfuscated nature of Easy '
                'Anti-Cheat Nyrna cannot manage titles that use this.'
                '\n\n'
                'If this is not the case for your application feel free to '
                '[file a bug](https://github.com/Merrit/nyrna/issues).',
            onTapLink: (String text, String? href, String title) {
              if (href == null) return;
              appsListCubit.launchURL(href);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _NoWindowsCard extends StatelessWidget {
  const _NoWindowsCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No windows that can be suspended'),
        ),
      ),
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppsListCubit, AppsListState>(
      builder: (context, state) {
        return (state.loading)
            ? Stack(
                children: [
                  ModalBarrier(color: Colors.grey.withOpacity(0.1)),
                  Transform.scale(
                    scale: 2,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
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
                    onPressed: () => appsListCubit.manualRefresh(),
                    child: const Icon(Icons.refresh),
                  );
                },
              )
            : Container();
      },
    );
  }
}
