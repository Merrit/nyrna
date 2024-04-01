import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';

import '../app/app.dart';
import '../core/core.dart';
import '../native_platform/src/window.dart';
import '../settings/cubit/settings_cubit.dart';
import '../theme/theme.dart';
import 'apps_list.dart';

/// The main screen for Nyrna.
///
/// Shows a ListView with tiles for each open window on the current desktop.
class AppsListPage extends StatefulWidget {
  static const id = 'running_apps_screen';

  const AppsListPage({super.key});

  @override
  State<AppsListPage> createState() => _AppsListPageState();
}

class _AppsListPageState extends State<AppsListPage> {
  @override
  void didChangeDependencies() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final firstRun = context.read<AppCubit>().state.firstRun;
      if (firstRun) _showFirstRunDialog();
    });

    super.didChangeDependencies();
  }

  final ScrollController scrollController = ScrollController();

  void _showFirstRunDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const FirstRunDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (appState.releaseNotes != null) {
              _showReleaseNotesDialog(context, appState.releaseNotes!);
            }
          });

          return BlocBuilder<AppsListCubit, AppsListState>(
            builder: (context, state) {
              List<Window> windows = state.windows;
              windows = _filterWindows(windows, state.windowFilter);

              return Stack(
                children: [
                  Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(10),
                      children: [
                        if (!state.loading && state.windows.isEmpty) ...[
                          const _NoWindowsCard(),
                        ] else ...[
                          ...windows.map(
                            (window) => WindowTile(
                              key: ValueKey(window),
                              window: window,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const _ProgressOverlay(),
                ],
              );
            },
          );
        },
      ),
      // We don't show a manual refresh button with a short auto-refresh.
      floatingActionButton: const _FloatingActionButton(),
    );
  }

  Future<void> _showReleaseNotesDialog(
    BuildContext context,
    ReleaseNotes releaseNotes,
  ) {
    final appCubit = context.read<AppCubit>();

    return showDialog(
      context: context,
      builder: (context) => ReleaseNotesDialog(
        releaseNotes: releaseNotes,
        donateCallback: () => appCubit.launchURL(kDonateUrl),
        launchURL: (url) => appCubit.launchURL(url),
        onClose: () {
          appCubit.dismissReleaseNotesDialog();
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Filters the list of windows based on the [windowFilter].
  List<Window> _filterWindows(List<Window> windows, String windowFilter) {
    return windows.where((window) {
      final executable = window.process.executable.toLowerCase();
      final title = window.title.toLowerCase();

      return executable.contains(windowFilter) || title.contains(windowFilter);
    }).toList();
  }
}

class _NoWindowsCard extends StatelessWidget {
  const _NoWindowsCard();

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
  const _ProgressOverlay();

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
  const _FloatingActionButton();

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
                    onPressed: () {
                      context.read<AppsListCubit>().manualRefresh();
                    },
                    child: const Icon(Icons.refresh),
                  );
                },
              )
            : Container();
      },
    );
  }
}
