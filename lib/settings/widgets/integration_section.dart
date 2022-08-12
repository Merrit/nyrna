import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/styles.dart';
import '../settings.dart';

/// Add shortcuts and icons for portable builds or autostart.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Spacers.verticalMedium,
        Text('System Integration'),
        Spacers.verticalXtraSmall,
        _AutostartTile(),
        _StartHiddenTile(),
      ],
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
          title: const Text('Start automatically at system boot'),
          value: state.autoStart,
          onChanged: (value) async {
            await settingsCubit.updateAutoStart(value);
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
          title: const Text('Start hidden in system tray'),
          value: state.startHiddenInTray,
          onChanged: (value) async {
            await settingsCubit.updateStartHiddenInTray(value);
          },
        );
      },
    );
  }
}
