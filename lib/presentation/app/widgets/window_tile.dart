import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';
import 'package:nyrna/application/app/app.dart';

/// Represents a visible window on the desktop, running state and actions.
class WindowTile extends StatelessWidget {
  final Window window;

  const WindowTile({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _StatusWidget(window: window),
        title: _TitleWidget(window: window),
        subtitle: _DetailsWidget(window: window),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 20,
        ),
        onTap: () async {
          final success = await context.read<AppCubit>().toggle(window);
          if (!success) await _showSnackError(context);
        },
      ),
    );
  }

  Future<void> _showSnackError(
    BuildContext context,
  ) async {
    final name = window.process.executable;
    final message = 'There was a problem interacting with $name';
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _StatusWidget extends StatelessWidget {
  final Window window;

  const _StatusWidget({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _color;
    switch (window.process.status) {
      case ProcessStatus.normal:
        _color = Colors.green;
        break;
      case ProcessStatus.suspended:
        _color = Colors.orange[700]!;
        break;
      case ProcessStatus.unknown:
        _color = Colors.grey;
    }

    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
      ),
    );
  }
}

class _TitleWidget extends StatelessWidget {
  final Window window;

  const _TitleWidget({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(window.title);
  }
}

class _DetailsWidget extends StatelessWidget {
  final Window window;

  const _DetailsWidget({
    Key? key,
    required this.window,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PID: ${window.process.pid}'),
        Text(window.process.executable),
      ],
    );
  }
}
