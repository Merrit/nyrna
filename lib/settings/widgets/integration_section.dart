import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/styles.dart';
import '../settings.dart';

/// Add shortcuts and icons for portable builds or autostart.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return const _WindowsIntegration();
    } else {
      return const SizedBox();
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
          trailing: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Switch(
                value: state.autoStartHotkey,
                onChanged: (value) async {
                  await settingsCubit.updateAutoStartHotkey(value);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
