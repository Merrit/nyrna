import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/theme.dart';
import '../settings.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ThemeChooser(),
        if (Platform.isWindows) const Divider(),
        if (Platform.isWindows) const _IconCustomizer(),
      ],
    );
  }
}

class _ThemeChooser extends StatelessWidget {
  const _ThemeChooser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme'),
            RadioListTile<AppTheme>(
              title: const Text('Dark'),
              groupValue: state.appTheme,
              value: AppTheme.dark,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: const Text('Pitch Black'),
              groupValue: state.appTheme,
              value: AppTheme.pitchBlack,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: const Text('Light'),
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

/// Choose a custom color for the tray icon.
class _IconCustomizer extends StatelessWidget {
  const _IconCustomizer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return ListTile(
          leading: ColorIndicator(
            color: state.trayIconColor,
          ),
          title: const Text('System tray icon color'),
          onTap: () => _pickIconColor(
            context: context,
            currentColor: state.trayIconColor,
          ),
        );
      },
    );
  }

  Future<void> _pickIconColor({
    required BuildContext context,
    required Color currentColor,
  }) async {
    Color iconColor = currentColor;
    final iconBytes = await settingsCubit.iconBytes();
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    // Current color is pre-selected.
                    color: iconColor,
                    onColorChanged: (Color color) {
                      setState(() => iconColor = color);
                    },
                    heading: const Text('Select color'),
                    subheading: const Text('Select color shade'),
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: false,
                    },
                  ),
                  Image.memory(
                    iconBytes,
                    height: 150,
                    width: 150,
                    color: iconColor,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await settingsCubit.updateIconColor(iconColor);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
