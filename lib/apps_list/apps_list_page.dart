import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app.dart';
import '../settings/cubit/settings_cubit.dart';
import '../theme/theme.dart';
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
  void didChangeDependencies() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final firstRun = context.read<AppCubit>().state.firstRun;
      if (firstRun) _showFirstRunDialog();
    });

    super.didChangeDependencies();
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
      body: BlocBuilder<AppsListCubit, AppsListState>(
        builder: (context, state) {
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
