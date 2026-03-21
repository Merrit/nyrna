import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../apps_list/apps_list.dart';
import '../app/app.dart';
import '../logs/logs.dart';
import 'loading.dart';

/// Intermediate loading screen while verifying that Nyrna's dependencies are
/// available. If they are not an error message is shown, preventing a crash.
class LoadingPage extends StatefulWidget {
  static const id = 'loading_screen';

  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // BlocListener only fires for state *changes* after the widget subscribes.
    // If checkDependencies() resolved before this widget was first mounted
    // (e.g. on KDE Wayland where it returns immediately), the cubit will
    // already be in LoadingSuccess when we first build.  In that case the
    // listener never fires, so we check the initial state here as well.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<LoadingCubit>().state;
      if (state is LoadingSuccess) {
        Navigator.pushReplacementNamed(context, AppsListPage.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
