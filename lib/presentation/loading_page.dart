import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/application/loading/loading.dart';

import 'app/app.dart';

/// Intermediate loading screen while verifying that Nyrna's dependencies are
/// available. If they are not an error message is shown, preventing a crash.
class LoadingPage extends StatelessWidget {
  static const id = 'loading_screen';

  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _log = Logger('LoadingScreen');
    _log.info('Loading screen initializing');

    return BlocProvider(
      create: (context) => LoadingCubit(),
      lazy: false,
      child: Scaffold(
        body: Center(
          child: BlocConsumer<LoadingCubit, LoadingState>(
            listener: (context, state) {
              if (state is LoadingSuccess) {
                Navigator.pushReplacementNamed(context, AppsPage.id);
              }
            },
            builder: (context, state) {
              if (state is LoadingFailed) {
                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text('''
Dependency check failed.

Please make sure you have installed Nyrna's dependencies.

(On Linux this would be wmctrl and xdotool)
                        '''),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
