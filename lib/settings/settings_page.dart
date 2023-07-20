import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logs/logs.dart';
import '../theme/styles.dart';
import 'settings.dart';

/// Show a loading dialog.
///
/// This is used when the app is working on something and the user should not be
/// able to interact with the app.
void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      // If working is already false because it was a quick operation, we don't
      // need to show the dialog.
      if (!context.read<SettingsCubit>().state.working) {
        Navigator.pop(context);
      }

      return BlocListener<SettingsCubit, SettingsState>(
        // Listen for when the app is no longer working and close the dialog.
        listener: (context, state) {
          if (!state.working) {
            Navigator.pop(context);
          }
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

class SettingsPage extends StatelessWidget {
  static const id = 'settings_page';

  SettingsPage({Key? key}) : super(key: key);

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.working) {
            _showLoadingDialog(context);
          }
        },
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 30,
            ),
            children: [
              const Donate(),
              Spacers.verticalLarge,
              const BehaviourSection(),
              Spacers.verticalMedium,
              const ThemeSection(),
              const IntegrationSection(),
              Spacers.verticalMedium,
              Text(
                AppLocalizations.of(context)!.troubleshootingTitle,
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(
                  AppLocalizations.of(context)!.logs,
                ),
                onTap: () => Navigator.pushNamed(context, LogPage.id),
              ),
              Spacers.verticalMedium,
              const AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}
