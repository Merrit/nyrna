import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/application/log/cubit/log_cubit.dart';

/// Display Nyrna's logs.
class LogPage extends StatelessWidget {
  static final id = 'log_page';

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
              Row(
                children: [
                  const Text('Log level'),
                  const SizedBox(width: 10),
                  BlocBuilder<LogCubit, LogState>(
                    builder: (context, state) {
                      return DropdownButton<Level>(
                        value: state.logLevel,
                        onChanged: (level) => logCubit.getLogsText(level!),
                        items: const [
                          DropdownMenuItem(
                            value: Level.INFO,
                            child: Text('INFO'),
                          ),
                          DropdownMenuItem(
                            value: Level.WARNING,
                            child: Text('WARNING'),
                          ),
                          DropdownMenuItem(
                            value: Level.SEVERE,
                            child: Text('SEVERE'),
                          ),
                          DropdownMenuItem(
                            value: Level.ALL,
                            child: Text('ALL'),
                          ),
                        ],
                      );
                    },
                  ),
                  Spacer(),
                  BlocBuilder<LogCubit, LogState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () async {
                          // Copy the visible logs to user's clipboard.
                          await Clipboard.setData(
                            ClipboardData(text: state.logsText),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logs copied to clipboard'),
                            ),
                          );
                        },
                        child: const Text('Copy'),
                      );
                    },
                  ),
                ],
              ),
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
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
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
