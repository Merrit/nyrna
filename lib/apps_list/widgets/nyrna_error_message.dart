import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app/app.dart';
import '../models/models.dart';

class NyrnaErrorMessage extends StatelessWidget {
  final InteractionError? interactionError;

  const NyrnaErrorMessage(this.interactionError, {super.key});

  @override
  Widget build(BuildContext context) {
    if (interactionError == null) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Encountered a problem attempting to ${interactionError!.interactionType.name}.',
          style: const TextStyle(fontSize: 18),
        ),
        const Text(
          '''
        This is sometimes resolved by running Nyrna with root / administrator privileges.
        
        Interacting with applications can go wrong for several reasons. In general, manipulating processes like this is known to be able to cause unpredictable results and there is usually not much Nyrna can do if it responds poorly, not at all, or crashes.
        
        This is why Nyrna comes with the disclaimer that things can go wrong, and you should be sure to always save your work and games.''',
        ),
        const Text(
          'More info',
          style: TextStyle(fontSize: 18),
        ),
        ExpansionTile(
          title: const Text('If this is a game...'),
          children: [
            MarkdownBody(
              data: '''
If this is a game, check if it uses `Easy Anti-Cheat` by searching for it at [pcgamingwiki.com](https://www.pcgamingwiki.com) and checking if the "Middleware" section lists Easy Anti-Cheat.

Due to the restricted and obfuscated nature of Easy Anti-Cheat Nyrna cannot manage titles that use this.''',
              onTapLink: (String text, String? href, String title) {
                if (href == null) return;
                AppCubit.instance.launchURL(href);
              },
              selectable: true,
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Report bug'),
          children: [
            MarkdownBody(
              data: '''
  If you believe this is an issue with Nyrna rather than a limitation of manipulating processes you can [create an issue](https://github.com/Merrit/nyrna/issues).
  
  For troubleshooting or to include in filing an issue you can obtain more detailed logs by:
  - Starting Nyrna with verbose logging, eg:
  
`nyrna --verbose`
  - Reproducing the error
  - Copying the logs from the settings page''',
              onTapLink: (String text, String? href, String title) {
                if (href == null) return;
                AppCubit.instance.launchURL(href);
              },
              selectable: true,
            ),
          ],
        ),
      ],
    );
  }
}
