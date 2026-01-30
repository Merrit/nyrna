import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/app_localizations.dart';
import '../../theme/theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

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
  const _ThemeChooser();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return RadioGroup<AppTheme>(
          groupValue: state.appTheme,
          onChanged: (value) {
            if (value != null) {
              themeCubit.changeTheme(value);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.themeTitle,
              ),
              RadioListTile<AppTheme>(
                title: Text(
                  AppLocalizations.of(context)!.dark,
                ),
                value: AppTheme.dark,
              ),
              RadioListTile<AppTheme>(
                title: Text(
                  AppLocalizations.of(context)!.pitchBlack,
                ),
                value: AppTheme.pitchBlack,
              ),
              RadioListTile<AppTheme>(
                title: Text(
                  AppLocalizations.of(context)!.light,
                ),
                value: AppTheme.light,
              ),
            ],
          ),
        );
      },
    );
  }
}
