import 'package:flutter/material.dart';
import 'package:nyrna/presentation/logs/logs.dart';
import 'package:nyrna/presentation/styles.dart';

import '../preferences.dart';

class PreferencesPage extends StatelessWidget {
  static const id = 'preferences_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: Scrollbar(
        isAlwaysShown: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 130,
          ),
          children: [
            const Donate(),
            Spacers.verticalLarge,
            const BehaviourSection(),
            Spacers.verticalMedium,
            const ThemeSection(),
            const IntegrationSection(),
            Spacers.verticalMedium,
            const Text('Troubleshooting'),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Logs'),
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
