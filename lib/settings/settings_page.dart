import 'package:flutter/material.dart';

import '../logs/logs.dart';
import '../presentation/styles.dart';
import 'widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  static const id = 'settings_page';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
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
