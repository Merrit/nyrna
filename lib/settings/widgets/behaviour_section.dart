import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

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
        const Text('Behaviour'),
        Spacers.verticalXtraSmall,
        ListTile(
          title: const Text('Auto Refresh'),
          leading: const Icon(Icons.refresh),
          subtitle: const Text('Update window & process info automatically'),
          trailing: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.autoRefresh,
                onChanged: (value) async {
                  await settingsCubit.updateAutoRefresh(value);
                },
              );
            },
          ),
        ),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListTile(
              leading: const Icon(Icons.timelapse),
              title: const Text('Auto Refresh Interval'),
              trailing: Text('${state.refreshInterval} seconds'),
              enabled: state.autoRefresh,
              onTap: () => _showRefreshIntervalDialog(context),
            );
          },
        ),
        const HotkeyConfigWidget(),
        ListTile(
          title: const Text('Close to tray'),
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
        const ShowHiddenTile(),
      ],
    );
  }

  /// Allow user to choose reset interval.
  void _showRefreshIntervalDialog(BuildContext context) async {
    final result = await showInputDialog(
      context: context,
      type: InputDialogs.onlyInt,
      title: 'Auto Refresh Interval',
      initialValue: settingsCubit.state.refreshInterval.toString(),
    );
    if (result == null) return;
    final newInterval = int.tryParse(result);
    if (newInterval == null) return;
    await settingsCubit.setRefreshInterval(newInterval);
    await settingsCubit.updateAutoRefresh();
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
          child: const Text('OK'),
          onPressed: _hotKey == null
              ? null
              : () {
                  settingsCubit.updateHotkey(_hotKey!);
                  Navigator.of(context).pop();
                },
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
      // title: const Text('Show hidden windows'),
      title: const Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Show hidden windows   '),
            WidgetSpan(
              child: Tooltip(
                message: 'Includes windows from other virtual desktops '
                    'and special windows that are not normally detected.',
                // textStyle: TextStyle(fontSize: 16),
                child: Icon(
                  Icons.help_outline,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      leading: const Icon(Icons.refresh),
      // subtitle: const Text('Includes windows from other virtual desktops '
      //     'and special windows that are not normally detected'),
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
