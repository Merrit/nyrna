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
    );
  }
}
