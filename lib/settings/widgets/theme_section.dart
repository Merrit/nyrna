import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../theme/theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
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
            Text(
              AppLocalizations.of(context)!.themeTitle,
            ),
            RadioListTile<AppTheme>(
              title: Text(
                AppLocalizations.of(context)!.dark,
              ),
              groupValue: state.appTheme,
              value: AppTheme.dark,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: Text(
                AppLocalizations.of(context)!.pitchBlack,
              ),
              groupValue: state.appTheme,
              value: AppTheme.pitchBlack,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: Text(
                AppLocalizations.of(context)!.light,
              ),
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
