import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:libadwaita/libadwaita.dart';

import '../../native_platform/native_platform.dart';
import '../apps_list.dart';

/// Passes the instance of [window] to child widgets.
class WindowCubit extends Cubit<Window> {
  WindowCubit(Window window) : super(window);
}

/// Represents a visible window on the desktop, running state and actions.
class WindowTile extends StatefulWidget {
  final Window window;

  const WindowTile({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  State<WindowTile> createState() => _WindowTileState();
}

class _WindowTileState extends State<WindowTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final window = widget.window;
    Color _statusColor;

    switch (window.process.status) {
      case ProcessStatus.normal:
        _statusColor = Colors.green;
        break;
      case ProcessStatus.suspended:
        _statusColor = Colors.orange[700]!;
        break;
      case ProcessStatus.unknown:
        _statusColor = Colors.grey;
    }

    return BlocProvider(
      create: (context) => WindowCubit(window),
      child: Card(
        child: Stack(
          children: [
            ListTile(
              leading: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (loading) ? null : _statusColor,
                ),
                child: (loading) ? const CircularProgressIndicator() : null,
              ),
              title: Text(window.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PID: ${window.process.pid}'),
                  Text(window.process.executable),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 20,
              ),
              onTap: () async {
                setState(() => loading = true);
                await context.read<AppsListCubit>().toggle(window);

                if (!mounted) return;
                setState(() => loading = false);
              },
              trailing: const _DetailsButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final window = context.select((WindowCubit cubit) => cubit.state);

    return BlocBuilder<AppsListCubit, AppsListState>(
      builder: (context, state) {
        final interactionError = state //
            .interactionErrors
            .singleWhereOrNull((element) => element.windowId == window.id);

        final errorText = (interactionError != null) ? '❗' : '';
        Widget errorIndicator = Text(
          errorText,
          style: const TextStyle(fontFamily: 'Noto Color Emoji'),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            errorIndicator,
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return _DetailsDialog(interactionError, window);
                  },
                );
              },
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        );
      },
    );
  }
}

class _DetailsDialog extends StatelessWidget {
  final InteractionError? interactionError;
  final Window window;

  const _DetailsDialog(
    this.interactionError,
    this.window, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GtkDialog(
      title: const Center(child: Text('Details')),
      padding: const EdgeInsets.all(12),
      children: [
        _ErrorMessage(interactionError),
        ListTile(
          title: const Text('Window Title'),
          subtitle: SelectableText(window.title),
          // trailing: Text(window.title),
        ),
        ListTile(
          title: const Text('Executable Name'),
          subtitle: SelectableText(window.process.executable),
          // trailing: Text(window.title),
        ),
        ListTile(
          title: const Text('PID'),
          subtitle: SelectableText(window.process.pid.toString()),
          // trailing: Text(window.title),
        ),
        ListTile(
          title: const Text('Current Status'),
          subtitle: SelectableText(window.process.status.name),
          // trailing: Text(window.title),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final InteractionError? interactionError;

  const _ErrorMessage(
    this.interactionError, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (interactionError == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Card(
        child: ExpansionTile(
          leading: const Text(
            '❗',
            style: TextStyle(fontFamily: 'Noto Color Emoji'),
          ),
          title: Text(
            'Encountered a problem attempting to ${interactionError!.interactionType.name}.',
          ),
          children: [
            const Text(
              'Interacting with applications can go wrong for several reasons.',
            ),
            ExpansionTile(
              title: const Text('If this is a game...'),
              children: [
                MarkdownBody(
                  data:
                      'If this is a game, check if it uses `Easy Anti-Cheat` by searching for it at '
                      '[pcgamingwiki.com](https://www.pcgamingwiki.com) and checking '
                      'if the "Middleware" section lists Easy Anti-Cheat.'
                      '\n\n'
                      'Due to the restricted and obfuscated nature of Easy '
                      'Anti-Cheat Nyrna cannot manage titles that use this.'
                      '\n\n'
                      'If this is not the case for your application feel free to '
                      '[file a bug](https://github.com/Merrit/nyrna/issues).',
                  onTapLink: (String text, String? href, String title) {
                    if (href == null) return;
                    appsListCubit.launchURL(href);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
