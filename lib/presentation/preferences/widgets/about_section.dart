import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/app.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Nyrna version'),
          subtitle: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return Text(state.runningVersion);
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: const Text('Nyrna homepage'),
          onTap: () => appCubit.launchURL('https://nyrna.merritt.codes'),
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: const Text('GitHub repository'),
          onTap: () => appCubit.launchURL('https://github.com/Merrit/nyrna'),
        ),
      ],
    );
  }
}
