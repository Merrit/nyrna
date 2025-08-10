import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../app/app.dart';
import '../../apps_list/apps_list.dart';
import '../../localization/app_localizations.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.aboutTitle,
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(
            AppLocalizations.of(context)!.version,
          ),
          subtitle: BlocBuilder<AppsListCubit, AppsListState>(
            builder: (context, state) {
              return Text(state.runningVersion);
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: Text(
            AppLocalizations.of(context)!.homepage,
          ),
          onTap: () => AppCubit.instance.launchURL(
            'https://nyrna.merritt.codes',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: Text(
            AppLocalizations.of(context)!.repository,
          ),
          onTap: () => AppCubit.instance.launchURL(
            'https://github.com/Merrit/nyrna',
          ),
        ),
      ],
    );
  }
}
