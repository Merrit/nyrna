import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';

import '../../styles.dart';

/// Add shortcuts and icons for portable builds or autostart.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return const _WindowsIntegration();
    } else {
      return const _LinuxIntegration();
    }
  }
}

class _WindowsIntegration extends StatelessWidget {
  const _WindowsIntegration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacers.verticalMedium,
        const Text('System Integration'),
        Spacers.verticalXtraSmall,
        ListTile(
          title: const Text('Start hotkey automatically at system startup'),
          leading: const Icon(Icons.add_circle_outline),
          trailing: BlocBuilder<PreferencesCubit, PreferencesState>(
            builder: (context, state) {
              return Switch(
                value: state.autoStartHotkey,
                onChanged: (value) async {
                  await preferencesCubit.updateAutoStartHotkey(value);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LinuxIntegration extends StatelessWidget {
  const _LinuxIntegration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return state.isPortable
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacers.verticalMedium,
                  const Text('System Integration'),
                  Spacers.verticalXtraSmall,
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Add Nyrna to launcher'),
                    onTap: () => _confirmAddToLauncher(context),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
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
}
