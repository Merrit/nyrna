import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/nyrna.dart';

import 'app/app.dart';

/// Intermediate loading screen while verifying that Nyrna's dependencies are
/// available. If they are not an error message is shown, preventing a crash.
class LoadingPage extends StatefulWidget {
  static const id = 'loading_screen';

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  static final _log = Logger('LoadingScreen');
  late Nyrna nyrna;

  @override
  void initState() {
    super.initState();
    _log.info('Loading screen initializing');
    nyrna = Nyrna.loading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: nyrna.checkDependencies(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final dependenciesPresent = snapshot.data!;
              if (dependenciesPresent) {
                // Slight delay required so we don't push the main
                // screen while the build method is still executing.
                Future.microtask(() {
                  Navigator.pushReplacementNamed(context, AppsPage.id);
                });
              } else {
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
              }
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Text('Error: ${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
