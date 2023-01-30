import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logs/logs.dart';
import '../theme/styles.dart';
import 'widgets/widgets.dart';

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
      body: Scrollbar(
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
    );
  }
}
