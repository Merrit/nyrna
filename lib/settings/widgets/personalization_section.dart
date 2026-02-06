import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localization/app_localizations.dart';
import '../../theme/styles.dart';
import '../cubit/settings_cubit.dart';

/// Personalization controls that apply to each process card.
class PersonalizationSection extends StatelessWidget {
  const PersonalizationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.personalizationTitle,
        ),
        Spacers.verticalXtraSmall,
        const _HidePidTile(),
        const _ExecutableFirstTile(),
        const _LimitWindowTitleTile(),
        const _CompactModeTile(),
        const _PinSuspendedWindowsTile(),
      ],
    );
  }
}

class _HidePidTile extends StatelessWidget {
  const _HidePidTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.hidePidSetting,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.hidePidSettingDescription,
          ),
          secondary: const Icon(Icons.visibility_off_outlined),
          value: state.hideProcessPid,
          onChanged: (value) async {
            await context.read<SettingsCubit>().updateHideProcessPid(value);
          },
        );
      },
    );
  }
}

class _ExecutableFirstTile extends StatelessWidget {
  const _ExecutableFirstTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.exeFirstSetting,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.exeFirstSettingDescription,
          ),
          secondary: const Icon(Icons.vertical_align_top),
          value: state.showExecutableFirst,
          onChanged: (value) async {
            await context
                .read<SettingsCubit>()
                .updateShowExecutableFirst(value);
          },
        );
      },
    );
  }
}

class _LimitWindowTitleTile extends StatelessWidget {
  const _LimitWindowTitleTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.limitWindowTitleToOneLine,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.limitWindowTitleToOneLineDescription,
          ),
          secondary: const Icon(Icons.wrap_text),
          value: state.limitWindowTitleToOneLine,
          onChanged: (value) async {
            await context
                .read<SettingsCubit>()
                .updateLimitWindowTitleToOneLine(value);
          },
        );
      },
    );
  }
}

class _CompactModeTile extends StatelessWidget {
  const _CompactModeTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.compactModeTitle,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.compactModeDescription,
          ),
          secondary: const Icon(Icons.compress),
          value: state.compactCards,
          onChanged: (value) async {
            await context.read<SettingsCubit>().updateCompactCards(value);
          },
        );
      },
    );
  }
}

class _PinSuspendedWindowsTile extends StatelessWidget {
  const _PinSuspendedWindowsTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SwitchListTile(
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${AppLocalizations.of(context)!.pinSuspendedWindows}   ',
                ),
                WidgetSpan(
                  child: Tooltip(
                    message:
                        AppLocalizations.of(context)!.pinSuspendedWindowsTooltip,
                    child: const Icon(
                      Icons.help_outline,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondary: const Icon(Icons.push_pin_outlined),
          value: state.pinSuspendedWindows,
          onChanged: (value) async {
            await context.read<SettingsCubit>().updatePinSuspendedWindows(value);
          },
        );
      },
    );
  }
}
