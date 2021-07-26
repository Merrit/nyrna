import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/cubit/app_cubit.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';
import 'package:nyrna/application/theme/theme.dart';
import 'package:nyrna/presentation/core/core.dart';
import 'package:nyrna/presentation/logs/logs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen with configuration settings for Nyrna.
class PreferencesPage extends StatelessWidget {
  static const id = 'preferences_page';

  final _divider = const Divider(
    indent: 20,
    endIndent: 20,
  );

  /// Adds a little space between sections.
  final _sectionPadding = const SizedBox(height: 50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 130,
        ),
        children: [
          Text('Preferences'),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Auto Refresh'),
            leading: Icon(Icons.refresh),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Update window & process info automatically'),
                const SizedBox(height: 5),
                if (Platform.isWindows) _WarningChip(),
              ],
            ),
            trailing: BlocBuilder<PreferencesCubit, PreferencesState>(
              builder: (context, state) {
                return Switch(
                  value: state.autoRefresh,
                  onChanged: (value) async {
                    await preferencesCubit.updateAutoRefresh(value);
                  },
                );
              },
            ),
          ),
          _divider,
          BlocBuilder<PreferencesCubit, PreferencesState>(
            builder: (context, state) {
              return ListTile(
                leading: const Icon(Icons.timelapse),
                title: Text('Auto Refresh Interval'),
                trailing: Text('${state.refreshInterval} seconds'),
                enabled: state.autoRefresh,
                onTap: () => _refreshIntervalDialog(context),
              );
            },
          ),
          // _divider,
          // ListTile(
          //   leading: Icon(Icons.color_lens),
          //   title: Text('Icon color'),
          //   trailing: ColorIndicator(),
          //   onTap: () => _pickIconColor(),
          // ),
          // Add shortcuts and icons for portable builds.
          if (Platform.isLinux) // TODO: Add integration function for Windows.
            BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return state.isPortable
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionPadding,
                          Text('System Integration'),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: Icon(Icons.add_circle_outline),
                            title: Text('Add Nyrna to launcher'),
                            onTap: () => _confirmAddToLauncher(context),
                          ),
                        ],
                      )
                    : const SizedBox();
              },
            ),
          _sectionPadding,
          ThemeSettings(),
          _sectionPadding,
          Text('Troubleshooting'),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text('Logs'),
            onTap: () => Navigator.pushNamed(context, LogPage.id),
          ),
          _sectionPadding,
          Text('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('Nyrna version'),
            subtitle: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return Text(state.runningVersion);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.launch),
            title: Text('Nyrna homepage'),
            onTap: () async {
              await launch('https://nyrna.merritt.codes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.launch),
            title: Text('GitHub repository'),
            onTap: () async {
              await launch('https://github.com/Merrit/nyrna');
            },
          ),
        ],
      ),
    );
  }

  /// Allow user to choose reset interval.
  void _refreshIntervalDialog(BuildContext context) async {
    final result = await showInputDialog(
      context: context,
      type: InputDialogs.onlyInt,
      title: 'Auto Refresh Interval',
      initialValue: preferencesCubit.state.refreshInterval.toString(),
    );
    if (result == null) return;
    final newInterval = int.tryParse(result);
    if (newInterval == null) return;
    await preferencesCubit.setRefreshInterval(newInterval);
    await preferencesCubit.updateAutoRefresh();
  }

//   Future<void> _pickIconColor() async {
//     var iconColor = Color(settings.iconColor);
//     final iconManager = IconManager();
//     final iconUint8List = await iconManager.iconUint8List;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ColorPicker(
//                     // Current color is pre-selected.
//                     color: iconColor,
//                     onColorChanged: (Color color) {
//                       setState(() => iconColor = color);
//                     },
//                     heading: Text('Select color'),
//                     subheading: Text('Select color shade'),
//                     pickersEnabled: const <ColorPickerType, bool>{
//                       ColorPickerType.primary: true,
//                       ColorPickerType.accent: false,
//                     },
//                   ),
//                   Image.memory(
//                     iconUint8List,
//                     height: 150,
//                     width: 150,
//                     color: iconColor,
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//     if (confirmed == null) return;
//     // await _updateIcon();
//     // await settings.setIconColor(newColor!.value);
//   }
}

/// Confirm with the user before adding .desktop and icon files.
void _confirmAddToLauncher(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 150.0,
          vertical: 24.0,
        ),
        content: const Text('This will add a menu item to the system '
            'launcher with an associated icon so launching Nyrna is easier.'
            '\n\n'
            'Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await preferencesCubit.createLauncher();
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
}

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme'),
            RadioListTile<AppTheme>(
              title: Text('Dark'),
              groupValue: state.appTheme,
              value: AppTheme.dark,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: Text('Pitch Black'),
              groupValue: state.appTheme,
              value: AppTheme.pitchBlack,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: Text('Light'),
              groupValue: state.appTheme,
              value: AppTheme.light,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
          ],
        );
      },
    );
  }
}

class _WarningChip extends StatelessWidget {
  const _WarningChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        'Caution',
        style: TextStyle(color: Colors.red[800]),
      ),
      backgroundColor: Colors.yellow,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'Note: Auto refresh can cause issues with memory consumption on '
                'Windows at the moment. Until the problem is resolved, consider '
                'keeping auto refresh off if you experience issues.',
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
      },
    );
  }
}
