import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app/app.dart';

/// Greets the user with a disclaimer about using the application.
class FirstRunDialog extends StatelessWidget {
  const FirstRunDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disclaimer'),
      content: const MarkdownBody(
        data: '''
Modifying running applications comes with the possibility that the application will crash.

While this is rare, it is a known possibility that Nyrna can do nothing about.

Please make sure to **save** your data or game before attempting to use Nyrna.''',
      ),
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () {
            AppCubit.instance.userAcceptedDisclaimer();
            Navigator.pop(context);
          },
          child: const Text('I understand'),
        )
      ],
    );
  }
}
