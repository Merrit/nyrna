import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/application/theme/theme.dart';

import '../app.dart';

/// The main screen for Nyrna.
///
/// Shows a ListView with tiles for each open window on the current desktop.
class AppsPage extends StatelessWidget {
  static const id = 'running_apps_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return (state == AppState.initial())
                  ? Transform.scale(
                      scale: 2,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 40),
                      children: [
                        ...state.windows
                            .map(
                              (window) => WindowTile(
                                key: ValueKey(window),
                                window: window,
                              ),
                            )
                            .toList(),
                      ],
                    );
            },
          ),
        ),
      ),
      // We don't show a manual refresh button with a short auto-refresh.
      floatingActionButton: _FloatingActionButton(),
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
