import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../apps_list/apps_list.dart';
import '../../presentation/styles.dart';

class Donate extends StatelessWidget {
  const Donate({Key? key}) : super(key: key);

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
                    const TextSpan(
                        text: 'Nyrna is free software, made with 💙 by '),
                    TextSpan(
                      text: 'Kristen McWilliam',
                      style: const TextStyle(color: Colors.lightBlueAccent),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          appsListCubit.launchURL('https://merritt.codes/');
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              Spacers.verticalXtraSmall,
              ElevatedButton.icon(
                onPressed: () {
                  appsListCubit.launchURL('https://merritt.codes/support');
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                label: const Text('Donate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
