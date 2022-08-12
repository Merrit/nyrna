import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ThemeChooser(),
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
