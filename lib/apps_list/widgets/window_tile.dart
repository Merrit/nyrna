import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../localization/app_localizations.dart';
import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../settings/settings.dart';
import '../../theme/styles.dart';
import '../apps_list.dart';

part 'window_tile.freezed.dart';

/// Passes the instance of [Window] to child widgets.
class WindowCubit extends Cubit<WindowState> {
  WindowCubit(Window window)
    : super(
        WindowState(
          window: window,
        ),
      );
}

@freezed
abstract class WindowState with _$WindowState {
  const factory WindowState({
    required Window window,
  }) = _WindowState;
}

const Key _windowTitleKey = Key('window-tile-title');

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

    final hidePid = context.select(
      (SettingsCubit cubit) => cubit.state.hideProcessPid,
    );
    final showExecutableFirst = context.select(
      (SettingsCubit cubit) => cubit.state.showExecutableFirst,
    );
    final limitWindowTitle = context.select(
      (SettingsCubit cubit) => cubit.state.limitWindowTitleToOneLine,
    );
    final compactCards = context.select(
      (SettingsCubit cubit) => cubit.state.compactCards,
    );

    final compactCards = context.select(
      (SettingsCubit cubit) => cubit.state.compactCards,
    );
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
      child: Builder(
        builder: (context) {
          final EdgeInsetsGeometry contentPadding = (compactCards)
              ? const EdgeInsets.symmetric(vertical: 2, horizontal: 18)
              : const EdgeInsets.symmetric(vertical: 4, horizontal: 20);
          final EdgeInsetsGeometry cardMargin = (compactCards)
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
          final double titleFontSize = compactCards ? 14.2 : 15;
          final double subtitleFontSize = compactCards ? 12.8 : 13.5;
          final double rowSpacing = compactCards ? 2 : 4;
          final TextTheme textTheme = Theme.of(context).textTheme;
          final TextStyle titleStyle = (textTheme.titleMedium ?? const TextStyle())
              .copyWith(fontSize: titleFontSize);
          final TextStyle subtitleStyle = (textTheme.bodyMedium ?? const TextStyle())
              .copyWith(fontSize: subtitleFontSize);
          final Color borderColor = compactCards
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.outline;
          return Card(
            margin: cardMargin,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadii.gentlyRounded,
              side: BorderSide(
                color: borderColor,
                width: compactCards ? 0.9 : 1,
              ),
            ),
            child: ListTile(
              visualDensity: compactCards
                  ? const VisualDensity(vertical: -2, horizontal: -1)
                  : VisualDensity.standard,
              leading: BlocBuilder<WindowCubit, WindowState>(
                builder: (context, state) {
                  return Container(
                    height: (compactCards) ? 22 : 25,
                    width: (compactCards) ? 22 : 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (loading) ? null : statusColor,
                    ),
                    child: (loading) ? const CircularProgressIndicator() : null,
                  );
                },
              ),
              dense: compactCards,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showExecutableFirst)
                    Text(
                      widget.window.process.executable,
                      key: const Key('window-tile-executable-first'),
                      style: subtitleStyle,
                    ),
                  if (showExecutableFirst)
                    SizedBox(
                      height: rowSpacing,
                    ),
                  Text(
                    widget.window.title,
                    key: _windowTitleKey,
                    style: titleStyle,
                    maxLines: (limitWindowTitle) ? 1 : null,
                    overflow: (limitWindowTitle) ? TextOverflow.ellipsis : null,
                  ),
                ],
              ),
              subtitle: _buildSubtitle(
                hidePid,
                showExecutableFirst,
                subtitleStyle,
                rowSpacing,
              ),
              contentPadding: contentPadding,
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
        },
      ),
    );
  }

  Widget? _buildSubtitle(
    bool hidePid,
    bool showExecutableFirst,
    TextStyle textStyle,
    double spacing,
  ) {
    final List<Widget> children = [];
    if (!hidePid) {
      children.add(
        Text(
          'PID: ${widget.window.process.pid}',
          key: const Key('window-tile-pid'),
          style: textStyle,
        ),
      );
    }
    if (!hidePid && !showExecutableFirst) {
      children.add(SizedBox(height: spacing));
    }
    if (!showExecutableFirst) {
      children.add(
        Text(
          widget.window.process.executable,
          key: const Key('window-tile-executable-subtitle'),
          style: textStyle,
        ),
      );
    }

    if (children.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
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

    return BlocBuilder<AppsListCubit, AppsListState>(
      builder: (context, state) {
        final toggleAllLabel = (window.process.status == ProcessStatus.normal)
            ? AppLocalizations.of(context)!.suspendAllInstances
            : AppLocalizations.of(context)!.resumeAllInstances;

        final toggleAllButton = MenuItemButton(
          child: Text(toggleAllLabel),
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

  String _getLocalizedStatus(BuildContext context, ProcessStatus status) {
    switch (status) {
      case ProcessStatus.normal:
        return AppLocalizations.of(context)!.statusNormal;
      case ProcessStatus.suspended:
        return AppLocalizations.of(context)!.statusSuspended;
      case ProcessStatus.unknown:
        return AppLocalizations.of(context)!.statusUnknown;
    }
  }

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
              subtitle: SelectableText(
                _getLocalizedStatus(context, window.process.status),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.close,
          ),
        ),
      ],
    );
  }
}
