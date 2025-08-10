import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/app_localizations.dart';
import 'logs.dart';

/// Display Nyrna's logs.
class LogPage extends StatelessWidget {
  static const id = 'log_page';

  LogPage({super.key});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogCubit(),
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
          child: Column(
            children: [
              BlocBuilder<LogCubit, LogState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () async {
                      final appLocalizations = AppLocalizations.of(context)!;
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      // Copy the visible logs to user's clipboard.
                      await Clipboard.setData(
                        ClipboardData(text: state.logsText),
                      );

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            appLocalizations.logsCopiedNotification,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.copyLogs,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Container(
                  color: Colors.grey[800],
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: BlocBuilder<LogCubit, LogState>(
                        builder: (context, state) {
                          return SelectableText(state.logsText);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
