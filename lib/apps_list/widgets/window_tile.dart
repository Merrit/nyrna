import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:helpers/helpers.dart';
import 'package:libadwaita/libadwaita.dart';

import '../../app/app.dart';
import '../../logs/logs.dart';
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
    Color statusColor;

    switch (window.process.status) {
      case ProcessStatus.normal:
        statusColor = Colors.green;
        break;
      case ProcessStatus.suspended:
        statusColor = Colors.orange[700]!;
        break;
      case ProcessStatus.unknown:
        statusColor = Colors.grey;
    }

    return BlocProvider(
      create: (context) => WindowCubit(window),
      child: _GestureDetector(
        child: Card(
          child: Stack(
            children: [
              ListTile(
                leading: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (loading) ? null : statusColor,
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
                  log.v('WindowTile clicked: $window');

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
      ),
    );
  }
}

/// Handles right-click on the WindowTile by showing a context menu.
class _GestureDetector extends StatelessWidget {
  final Widget child;

  const _GestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowCubit, Window>(
      builder: (context, window) {
        final availableAction = (window.process.status == ProcessStatus.normal)
            ? 'Suspend'
            : 'Resume';

        return GestureDetector(
          onSecondaryTapUp: (details) {
            showContextMenu(
              context: context,
              offset: details.globalPosition,
              items: [
                PopupMenuItem(
                  onTap: () => appsListCubit.toggleAll(window),
                  child: Text(
                    '$availableAction all instances of ${window.process.executable}',
                  ),
                ),
              ],
            );
          },
          child: child,
        );
      },
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
      title: Center(
        child: Text(
          AppLocalizations.of(context)!.detailsDialogTitle,
        ),
      ),
      padding: const EdgeInsets.all(12),
      children: [
        _ErrorMessage(interactionError),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.detailsDialogWindowTitle,
          ),
          subtitle: SelectableText(window.title),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.detailsDialogExecutableName,
          ),
          subtitle: SelectableText(window.process.executable),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.detailsDialogPID,
          ),
          subtitle: SelectableText(window.process.pid.toString()),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.detailsDialogCurrentStatus,
          ),
          subtitle: SelectableText(window.process.status.name),
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
              '''
Interacting with applications can go wrong for several reasons. In general, manipulating processes like this is known to be able to cause unpredictable results and there is usually not much Nyrna can do if it responds poorly, not at all, or crashes.

This is why Nyrna comes with the disclaimer that things can go wrong, and you should be sure to always save your work and games.''',
            ),
            const Divider(),
            const Text('More info'),
            ExpansionTile(
              title: const Text('If this is a game...'),
              children: [
                MarkdownBody(
                  data: '''
If this is a game, check if it uses `Easy Anti-Cheat` by searching for it at [pcgamingwiki.com](https://www.pcgamingwiki.com) and checking if the "Middleware" section lists Easy Anti-Cheat.

Due to the restricted and obfuscated nature of Easy Anti-Cheat Nyrna cannot manage titles that use this.''',
                  onTapLink: (String text, String? href, String title) {
                    if (href == null) return;
                    AppCubit.instance.launchURL(href);
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Report bug'),
              children: [
                MarkdownBody(
                  data: '''
If you believe this is an issue with Nyrna rather than a limitation of manipulating processes you can [create an issue](https://github.com/Merrit/nyrna/issues).

For troubleshooting or to include in filing an issue you can obtain more detailed logs by:
- Starting Nyrna with verbose logging, eg: `nyrna --verbose`
- Reproducing the error
- Copying the logs from the settings page''',
                  onTapLink: (String text, String? href, String title) {
                    if (href == null) return;
                    AppCubit.instance.launchURL(href);
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
