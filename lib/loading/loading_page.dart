import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../apps_list/apps_list.dart';
import '../app/app.dart';
import '../logs/logs.dart';
import 'loading.dart';

/// Intermediate loading screen while verifying that Nyrna's dependencies are
/// available. If they are not an error message is shown, preventing a crash.
class LoadingPage extends StatelessWidget {
  static const id = 'loading_screen';

  const LoadingPage({super.key});

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
              switch (state) {
                case LoadingError():
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: MarkdownBody(
                          data: state.errorMsg,
                          onTapLink: (text, href, title) {
                            if (href == null) {
                              log.e('Broken link: $href');
                              return;
                            }

                            AppCubit.instance.launchURL(href);
                          },
                        ),
                      ),
                    ),
                  );
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
