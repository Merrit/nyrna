import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../apps_list/apps_list.dart';
import '../../hotkey/hotkey_service.dart';
import '../../theme/styles.dart';
import '../settings.dart';

/// Add shortcuts and icons for portable builds or autostart.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacers.verticalMedium,
        Text(
          AppLocalizations.of(context)!.systemIntegrationTitle,
        ),
        Spacers.verticalXtraSmall,
        const _CloseToTrayTile(),
        const _AutostartTile(),
        const _StartHiddenTile(),
        const _HotkeyConfigWidget(),
        const _AppSpecificHotkeys(),
      ],
    );
  }
}

class _CloseToTrayTile extends StatelessWidget {
  const _CloseToTrayTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}

class _AutostartTile extends StatelessWidget {
  const _AutostartTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: const Icon(Icons.start),
          title: Text(
            AppLocalizations.of(context)!.startAutomatically,
          ),
          value: state.autoStart,
          onChanged: (_) async {
            await settingsCubit.toggleAutostart();
          },
        );
      },
    );
  }
}

class _StartHiddenTile extends StatelessWidget {
  const _StartHiddenTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (!state.closeToTray || !state.autoStart) {
          return const SizedBox();
        }

        return SwitchListTile(
          secondary: const Icon(Icons.auto_awesome),
          title: Text(
            AppLocalizations.of(context)!.startInTray,
          ),
          value: state.startHiddenInTray,
          onChanged: (value) async {
            await settingsCubit.updateStartHiddenInTray(value);
          },
        );
      },
    );
  }
}

class _HotkeyConfigWidget extends StatelessWidget {
  const _HotkeyConfigWidget({
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
          builder: (context) => _RecordHotKeyDialog(
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

class _RecordHotKeyDialog extends StatefulWidget {
  final HotKey initialHotkey;

  const _RecordHotKeyDialog({
    Key? key,
    required this.initialHotkey,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecordHotKeyDialogState createState() => _RecordHotKeyDialogState();
}

class _RecordHotKeyDialogState extends State<_RecordHotKeyDialog> {
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

/// Hotkeys to toggle specific apps.
class _AppSpecificHotkeys extends StatelessWidget {
  const _AppSpecificHotkeys({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) return const SizedBox();

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Card(
          child: Column(
            children: [
              const ListTile(
                title: Text('App specific hotkeys'),
                leading: Icon(Icons.keyboard),
                trailing: Tooltip(
                  message:
                      'Hotkeys to directly toggle suspend/resume for specific apps, even when they are not focused.',
                  child: Icon(Icons.help_outline),
                ),
              ),
              for (var hotkey in state.appSpecificHotKeys)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Text(hotkey.hotkey.toStringHelper()),
                      title: Text(hotkey.executable),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: () => settingsCubit
                            .removeAppSpecificHotkey(hotkey.executable),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const _AddAppSpecificHotkeyDialog(),
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _AddAppSpecificHotkeyDialog extends StatelessWidget {
  const _AddAppSpecificHotkeyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: BlocBuilder<AppsListCubit, AppsListState>(
        builder: (context, state) {
          final executables = state.windows
              .map((window) => window.process.executable)
              .toSet()
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add app specific hotkey'),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: null,
                hint: const Text('Select app'),
                items: executables.map((executable) {
                  return DropdownMenuItem<String>(
                    value: executable,
                    child: Text(executable),
                  );
                }).toList(),
                onChanged: (executable) async {
                  if (executable == null) return;

                  final navigator = Navigator.of(context);

                  await showDialog(
                    context: context,
                    builder: (context) => _RecordAppSpecificHotkeyDialog(
                      executable: executable,
                    ),
                  );

                  navigator.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordAppSpecificHotkeyDialog extends StatefulWidget {
  final String executable;

  const _RecordAppSpecificHotkeyDialog({
    Key? key,
    required this.executable,
  }) : super(key: key);

  @override
  _RecordAppSpecificHotkeyDialogState createState() =>
      _RecordAppSpecificHotkeyDialogState();
}

class _RecordAppSpecificHotkeyDialogState
    extends State<_RecordAppSpecificHotkeyDialog> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text('Record a new hotkey'),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _hotKey == null
              ? null
              : () {
                  settingsCubit.addAppSpecificHotkey(
                    widget.executable,
                    _hotKey!,
                  );
                  Navigator.of(context).pop();
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
