import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


import '../../app/app.dart';
import '../../localization/app_localizations.dart';
import '../../theme/styles.dart';

class Donate extends StatelessWidget {
  const Donate({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.madeBy,
                      style: const TextStyle(
                        fontFamily: emojiFont,
                      ),
                    ),
                    TextSpan(
                      text: 'Kristen McWilliam',
                      style: const TextStyle(color: Colors.lightBlueAccent),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AppCubit.instance.launchURL('https://merritt.codes/');
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              Text(
                AppLocalizations.of(context)!.donateMessage,
                textAlign: TextAlign.center,
              ),
              Spacers.verticalXtraSmall,
              FilledButton.icon(
                onPressed: () {
                  AppCubit.instance.launchURL('https://merritt.codes/support');
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                label: Text(
                  AppLocalizations.of(context)!.donate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
