import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/theme/theme.dart';
import 'package:nyrna/presentation/logs/pages/log_page.dart';
import 'package:nyrna/presentation/loading_page.dart';
import 'package:nyrna/presentation/preferences/pages/preferences_page.dart';
import 'package:provider/provider.dart';

import '../nyrna.dart';
import 'app/app.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Nyrna>(create: (_) => Nyrna()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Nyrna',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            routes: {
              LoadingPage.id: (context) => LoadingPage(),
              LogPage.id: (context) => LogPage(),
              AppsPage.id: (context) => AppsPage(),
              PreferencesPage.id: (conext) => PreferencesPage(),
            },
            home: LoadingPage(),
          );
        },
      ),
    );
  }
}
