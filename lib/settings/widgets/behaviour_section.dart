import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../apps_list/apps_list.dart';
import '../../core/core.dart';
import '../../hotkey/hotkey_service.dart';
import '../../theme/styles.dart';
import '../cubit/settings_cubit.dart';

class BehaviourSection extends StatelessWidget {
  const BehaviourSection({Key? key}) : super(key: key);

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
        const HotkeyConfigWidget(),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.closeToTray,
          ),
          leading: const Icon(Icons.bedtime),
          trailing: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.closeToTray,
                onChanged: (value) async {
                  await settingsCubit.updateCloseToTray(value);
                },
              );
            },
          ),
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

class HotkeyConfigWidget extends StatelessWidget {
  const HotkeyConfigWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hotkey service not working properly on Linux..
    if (Platform.isLinux) return const SizedBox();

    return ListTile(
      title: const Text('Hotkey'),
      leading: const Icon(Icons.keyboard),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => RecordHotKeyDialog(
            initialHotkey: settingsCubit.state.hotKey,
          ),
        ),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return Text(state.hotKey.toStringHelper());
          },
        ),
      ),
    );
  }
}

class RecordHotKeyDialog extends StatefulWidget {
  final HotKey initialHotkey;

  const RecordHotKeyDialog({
    Key? key,
    required this.initialHotkey,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecordHotKeyDialogState createState() => _RecordHotKeyDialogState();
}

class _RecordHotKeyDialogState extends State<RecordHotKeyDialog> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    settingsCubit.removeHotkey();

    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(
              children: [
                const Text('Record a new hotkey'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    settingsCubit.resetHotkey();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            Container(
              width: 100,
              height: 60,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  HotKeyRecorder(
                    initalHotKey: widget.initialHotkey,
                    onHotKeyRecorded: (hotKey) {
                      _hotKey = hotKey;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            settingsCubit.updateHotkey(widget.initialHotkey);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _hotKey == null
              ? null
              : () {
                  settingsCubit.updateHotkey(_hotKey!);
                  Navigator.of(context).pop();
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class ShowHiddenTile extends StatelessWidget {
  const ShowHiddenTile({Key? key}) : super(key: key);

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
