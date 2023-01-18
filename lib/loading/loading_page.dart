import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../apps_list/apps_list.dart';
import 'loading.dart';

/// Intermediate loading screen while verifying that Nyrna's dependencies are
/// available. If they are not an error message is shown, preventing a crash.
class LoadingPage extends StatelessWidget {
  static const id = 'loading_screen';

  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoadingCubit(),
      lazy: false,
      child: Scaffold(
        body: Center(
          child: BlocConsumer<LoadingCubit, LoadingState>(
            listener: (context, state) {
              if (state is LoadingSuccess) {
                Navigator.pushReplacementNamed(context, AppsListPage.id);
              }
            },
            builder: (context, state) {
              if (state is LoadingFailed) {
                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: const MarkdownBody(data: '''
Dependency check failed.

Install the dependencies from your system's package manager:

- `xdotool`
- `wmctrl`
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
