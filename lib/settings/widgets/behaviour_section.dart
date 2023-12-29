import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../apps_list/apps_list.dart';
import '../../core/core.dart';
import '../../theme/styles.dart';
import '../cubit/settings_cubit.dart';

class BehaviourSection extends StatelessWidget {
  const BehaviourSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.behaviourTitle,
        ),
        Spacers.verticalXtraSmall,
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.autoRefresh,
          ),
          leading: const Icon(Icons.refresh),
          subtitle: Text(
            AppLocalizations.of(context)!.autoRefreshDescription,
          ),
          trailing: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.autoRefresh,
                onChanged: (value) async {
                  final appsListCubit = context.read<AppsListCubit>();
                  await settingsCubit.updateAutoRefresh(value);
                  appsListCubit.setAutoRefresh(
                    autoRefresh: value,
                    refreshInterval: state.refreshInterval,
                  );
                },
              );
            },
          ),
        ),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListTile(
              leading: const Icon(Icons.timelapse),
              title: Text(
                AppLocalizations.of(context)!.autoRefreshInterval,
              ),
              trailing: Text(
                AppLocalizations.of(context)!
                    .autoRefreshIntervalAmount(state.refreshInterval),
              ),
              enabled: state.autoRefresh,
              onTap: () => _showRefreshIntervalDialog(context),
            );
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.minimizeAndRestoreWindows,
          ),
          leading: const Icon(Icons.minimize),
          trailing: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.minimizeWindows,
                onChanged: (value) async {
                  await settingsCubit.updateMinimizeWindows(value);
                },
              );
            },
          ),
        ),
        const ShowHiddenTile(),
      ],
    );
  }

  /// Allow user to choose reset interval.
  void _showRefreshIntervalDialog(BuildContext context) async {
    final result = await showInputDialog(
      context: context,
      type: InputDialogs.onlyInt,
      title: AppLocalizations.of(context)!.autoRefreshInterval,
      initialValue: settingsCubit.state.refreshInterval.toString(),
    );
    if (result == null) return;
    final newInterval = int.tryParse(result);
    if (newInterval == null) return;
    await settingsCubit.setRefreshInterval(newInterval);
  }
}

class ShowHiddenTile extends StatelessWidget {
  const ShowHiddenTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${AppLocalizations.of(context)!.showHiddenWindows}   ',
            ),
            WidgetSpan(
              child: Tooltip(
                message: AppLocalizations.of(context)!.showHiddenWindowsTooltip,
                child: const Icon(
                  Icons.help_outline,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      leading: const Icon(Icons.refresh),
      trailing: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Switch(
            value: state.showHiddenWindows,
            onChanged: (value) async {
              await settingsCubit.updateShowHiddenWindows(value);
            },
          );
        },
      ),
    );
  }
}
