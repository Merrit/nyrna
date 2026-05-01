import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hotkey_manager/hotkey_manager.dart';

import '../../app/app.dart';
import '../../apps_list/apps_list.dart';
import '../../core/core.dart';
import '../../localization/app_localizations.dart';
import '../../native_platform/native_platform.dart';
import '../../theme/styles.dart';
import '../settings.dart';

// Quick hack, should be moved to a more appropriate place later.
bool _isWayland(BuildContext context) {
  final sessionType = context.read<AppCubit>().state.sessionType;
  return sessionType?.displayProtocol == DisplayProtocol.wayland;
}

/// Add shortcuts and icons for portable builds or autostart.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({super.key});

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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.closeToTray,
          ),
          secondary: const Icon(Icons.bedtime),
          value: state.closeToTray,
          onChanged: (bool value) async {
            await settingsCubit.updateCloseToTray(value);

            if (state.startHiddenInTray && !value) {
              await settingsCubit.updateStartHiddenInTray(false);
            }
          },
        );
      },
    );
  }
}

class _AutostartTile extends StatelessWidget {
  const _AutostartTile();

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
          onChanged: (bool value) async {
            await settingsCubit.toggleAutostart();

            if (state.startHiddenInTray && !value) {
              await settingsCubit.updateStartHiddenInTray(false);
            }
          },
        );
      },
    );
  }
}

class _StartHiddenTile extends StatelessWidget {
  const _StartHiddenTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: const Icon(Icons.auto_awesome),
          title: Text(
            AppLocalizations.of(context)!.startInTray,
          ),
          value: state.startHiddenInTray,
          onChanged: (bool value) async {
            if (!state.closeToTray && value) {
              await settingsCubit.updateCloseToTray(true);
            }

            if (!state.autoStart && value) {
              await settingsCubit.toggleAutostart();
            }

            await settingsCubit.updateStartHiddenInTray(value);
          },
        );
      },
    );
  }
}

class _HotkeyConfigWidget extends StatelessWidget {
  const _HotkeyConfigWidget();

  @override
  Widget build(BuildContext context) {
    if (_isWayland(context)) {
      // Hotkey manager doesn't work on Wayland, so we hide the hotkey settings in that
      // case. Instead show a web link to the docs about how to setup a custom hotkey
      // through the DE.
      return ListTile(
        leading: const Icon(Icons.keyboard),
        title: Text(
          AppLocalizations.of(context)!.hotkey,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.waylandHotkeyMessage,
            ),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => context.read<AppCubit>().launchURL(kWaylandHotkeyDocsUrl),
              child: Text(
                AppLocalizations.of(context)!.waylandHotkeyDocsLink,
              ),
            ),
          ],
        ),
      );
    }

    return ListTile(
      title: Text(
        AppLocalizations.of(context)!.hotkey,
      ),
      leading: const Icon(Icons.keyboard),
      trailing: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _RecordHotKeyDialog(
            initialHotkey: settingsCubit.state.hotKey,
          ),
        ),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return Text(state.hotKey.debugName);
          },
        ),
      ),
    );
  }
}

class _RecordHotKeyDialog extends StatefulWidget {
  final HotKey initialHotkey;

  const _RecordHotKeyDialog({
    required this.initialHotkey,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RecordHotKeyDialogState createState() => _RecordHotKeyDialogState();
}

class _RecordHotKeyDialogState extends State<_RecordHotKeyDialog> {
  @override
  void initState() {
    super.initState();
    settingsCubit.removeHotkey();
  }

  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.recordNewHotkey,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    settingsCubit.resetHotkey();
                    Navigator.pop(context);
                  },
                ),
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
          child: Text(
            AppLocalizations.of(context)!.cancel,
          ),
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
          child: Text(
            AppLocalizations.of(context)!.confirm,
          ),
        ),
      ],
    );
  }
}

/// Hotkeys to toggle specific apps.
class _AppSpecificHotkeys extends StatelessWidget {
  const _AppSpecificHotkeys();

  @override
  Widget build(BuildContext context) {
    if (_isWayland(context)) {
      // Global hotkeys don't work on Wayland.
      return const SizedBox();
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.appSpecificHotkeys,
                ),
                leading: const Icon(Icons.keyboard),
                trailing: Tooltip(
                  message: AppLocalizations.of(context)!.appSpecificHotkeysTooltip,
                  child: const Icon(Icons.help_outline),
                ),
              ),
              for (var hotkey in state.appSpecificHotKeys)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Text(hotkey.hotkey.debugName),
                      title: Text(hotkey.executable),
                      trailing: ElevatedButton(
                        onPressed: () => settingsCubit.removeAppSpecificHotkey(
                          hotkey.executable,
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ),
                ),
              ElevatedButton(
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
  const _AddAppSpecificHotkeyDialog();

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
              Text(
                AppLocalizations.of(context)!.addAppSpecificHotkey,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: null,
                hint: Text(
                  AppLocalizations.of(context)!.selectApp,
                ),
                items: executables.map((executable) {
                  return DropdownMenuItem<String>(
                    value: executable,
                    child: Text(executable),
                  );
                }).toList(),
                isExpanded: true,
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
    required this.executable,
  });

  @override
  _RecordAppSpecificHotkeyDialogState createState() =>
      _RecordAppSpecificHotkeyDialogState();
}

class _RecordAppSpecificHotkeyDialogState extends State<_RecordAppSpecificHotkeyDialog> {
  HotKey? _hotKey;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.recordNewHotkey,
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
          child: Text(
            AppLocalizations.of(context)!.cancel,
          ),
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
          child: Text(
            AppLocalizations.of(context)!.confirm,
          ),
        ),
      ],
    );
  }
}
