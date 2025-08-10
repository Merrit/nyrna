import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../localization/app_localizations.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../apps_list.dart';

part 'window_tile.freezed.dart';

/// Passes the instance of [Window] to child widgets.
class WindowCubit extends Cubit<WindowState> {
  WindowCubit(Window window)
      : super(WindowState(
          window: window,
        ));
}

@freezed
class WindowState with _$WindowState {
  const factory WindowState({
    required Window window,
  }) = _WindowState;
}

/// Represents a visible window on the desktop, running state and actions.
class WindowTile extends StatefulWidget {
  final Window window;

  const WindowTile({
    super.key,
    required this.window,
  });

  @override
  State<WindowTile> createState() => _WindowTileState();
}

class _WindowTileState extends State<WindowTile> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (widget.window.process.status) {
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
      create: (context) => WindowCubit(widget.window),
      child: Builder(builder: (context) {
        return Card(
          child: ListTile(
            leading: BlocBuilder<WindowCubit, WindowState>(
              builder: (context, state) {
                return Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (loading) ? null : statusColor,
                  ),
                  child: (loading) ? const CircularProgressIndicator() : null,
                );
              },
            ),
            title: Text(widget.window.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PID: ${widget.window.process.pid}'),
                Text(widget.window.process.executable),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 20,
            ),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FavoriteButton(),
                _DetailsButton(),
              ],
            ),
            onTap: () async {
              log.i('WindowTile clicked: ${widget.window}');

              setState(() => loading = true);
              await context.read<AppsListCubit>().toggle(widget.window);

              if (!mounted) return;
              setState(() => loading = false);
            },
          ),
        );
      }),
    );
  }
}

/// Button to toggle the favorite status of a window.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    final appsListCubit = context.read<AppsListCubit>();

    final window = context.select((WindowCubit cubit) => cubit.state.window);
    final isFavorite = window.process.isFavorite;

    return IconButton(
      icon: Icon(
        (isFavorite) ? Icons.favorite : Icons.favorite_border,
        color: (isFavorite) ? Colors.red : null,
      ),
      onPressed: () => appsListCubit.setFavorite(window, !isFavorite),
      tooltip: (isFavorite)
          ? AppLocalizations.of(context)!.favoriteButtonTooltipRemove
          : AppLocalizations.of(context)!.favoriteButtonTooltipAdd,
    );
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton();

  @override
  Widget build(BuildContext context) {
    final window = context.select((WindowCubit cubit) => cubit.state.window);

    final availableAction =
        (window.process.status == ProcessStatus.normal) ? 'Suspend' : 'Resume';

    return BlocBuilder<AppsListCubit, AppsListState>(
      builder: (context, state) {
        final toggleAllButton = MenuItemButton(
          child: Text('$availableAction all instances'),
          onPressed: () => context.read<AppsListCubit>().toggleAll(window),
        );

        final Widget moreActionsButton = MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert),
            );
          },
          menuChildren: [
            MenuItemButton(
              child: Text(AppLocalizations.of(context)!.detailsDialogTitle),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return _DetailsDialog(window);
                  },
                );
              },
            ),
            toggleAllButton,
          ],
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            moreActionsButton,
          ],
        );
      },
    );
  }
}

class _DetailsDialog extends StatelessWidget {
  final Window window;

  const _DetailsDialog(this.window);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          AppLocalizations.of(context)!.detailsDialogTitle,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
