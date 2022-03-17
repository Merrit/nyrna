import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_platform/native_platform.dart';

import '../../../application/app/app.dart';

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

    return Card(
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
              final success = await context.read<AppCubit>().toggle(window);
              if (!success) await _showSnackError(context);
              setState(() => loading = false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSnackError(BuildContext context) async {
    final name = widget.window.process.executable;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('There was a problem interacting with $name')),
    );
  }
}
