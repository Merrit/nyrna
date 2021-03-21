import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/window/window.dart';
import 'package:provider/provider.dart';

/// Represents a visible window on the desktop, running state and actions.
class WindowTile extends StatefulWidget {
  WindowTile({this.window, this.key});

  /// Key is overridden to ensure unique, non-double entries.
  @override
  final Key key;

  /// The visible window.
  final Window window;

  @override
  _WindowTileState createState() => _WindowTileState();
}

class _WindowTileState extends State<WindowTile> {
  /// The process associated with the window.
  Process process;

  /// The visible window.
  Window window;

  @override
  void initState() {
    super.initState();
    window = widget.window;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      process = Provider.of<Process>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _statusWidget(),
        title: Text(window.title),
        subtitle: _executableNameWidget(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 20,
        ),
        onTap: () => _toggle(),
      ),
    );
  }

  /// Show the process' suspend status. Green = normal, orange = suspended.
  Widget _statusWidget() {
    return Consumer<Process>(
      builder: (context, process, widget) {
        return FutureBuilder(
          future: process.status,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }
            var _circleStatusColor = (snapshot.data == ProcessStatus.suspended)
                ? Colors.orange[700]
                : Colors.green;
            return Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _circleStatusColor,
              ),
            );
          },
        );
      },
    );
  }

  /// Executable name, for example 'firefox' or 'firefox-bin'.
  Widget _executableNameWidget() {
    return FutureBuilder(
      future: Provider.of<Process>(context, listen: false).executable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data);
        }
        return const Text('');
      },
    );
  }

  /// Toggle suspend / resume for the process associated with the given window.
  Future<void> _toggle() async {
    final _status = await process.status;
    if (_status == ProcessStatus.suspended) {
      await _resume();
    } else {
      await _suspend();
    }
  }

  Future<void> _suspend() async {
    // Minimize the window before suspending or it might not minimize.
    await window.minimize();
    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (Platform.isWindows) await Future.delayed(Duration(milliseconds: 500));
    final successful = await process.toggle();
    if (!successful) await _showSnackError(_ToggleError.Suspend);
  }

  Future<void> _resume() async {
    final successful = await process.toggle();
    if (!successful) await _showSnackError(_ToggleError.Resume);
    // Restore the window _after_ resuming or it might not restore.
    await window.restore();
  }

  Future<void> _showSnackError(_ToggleError errorType) async {
    final name = await process.executable;
    final suspendMessage = 'There was a problem suspending $name';
    final resumeMessage = 'There was a problem resuming $name';
    final message =
        (errorType == _ToggleError.Suspend) ? suspendMessage : resumeMessage;
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

enum _ToggleError {
  Suspend,
  Resume,
}
