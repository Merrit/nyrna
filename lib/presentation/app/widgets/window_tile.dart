import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';

import 'package:nyrna/application/app/app.dart';

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

    return Card(
      child: Stack(
        children: [
          ListTile(
            leading: _StatusWidget(loading: loading, window: window),
            title: _TitleWidget(window: window),
            subtitle: _DetailsWidget(window: window),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 20,
            ),
            onTap: () async {
              setState(() => loading = true);
              final success = await context.read<AppCubit>().toggle(window);
              if (!success) await _showSnackError(context);
              setState(() => loading = false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSnackError(
    BuildContext context,
  ) async {
    final name = widget.window.process.executable;
    final message = 'There was a problem interacting with $name';
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _StatusWidget extends StatelessWidget {
  final Window window;
  final bool loading;

  const _StatusWidget({
    Key? key,
    required this.window,
    required this.loading,
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
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (loading) ? null : _color,
      ),
      child: (loading) ? CircularProgressIndicator() : null,
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
