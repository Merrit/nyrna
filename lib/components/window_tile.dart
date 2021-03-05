import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyrna/process/process.dart';
import 'package:nyrna/process/process_status.dart';
import 'package:nyrna/window/window.dart';
import 'package:provider/provider.dart';

class WindowTile extends StatefulWidget {
  final Window window;
  final Key key;

  WindowTile({this.window, this.key});

  @override
  _WindowTileState createState() => _WindowTileState();
}

class _WindowTileState extends State<WindowTile> {
  Process process;
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
    return GestureDetector(
      onTap: () => _toggle(),
      child: Card(
        child: ListTile(
          leading: _statusWidget(),
          title: Text(window.title),
          subtitle: _executableNameWidget(),
          contentPadding: EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _statusWidget() {
    return Consumer<Process>(
      builder: (context, process, widget) {
        return FutureBuilder(
          future: process.status,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {}
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
        return Text('');
      },
    );
  }

  _toggle() async {
    var _status = await process.status;
    if (_status == ProcessStatus.suspended) {
      // Resume.
      bool successful = await process.toggle();
      if (!successful) {
        // TODO: Notify of failure.
      }
      // Restore the window _after_ resuming or it might not restore.
      await window.restore();
    } else {
      // Suspend.
      // Minimize the window before suspending or it might not minimize.
      await window.minimize();
      // Small delay on Windows to ensure the window actually minimizes.
      // Doesn't seem to be necessary on Linux.
      if (Platform.isWindows) await Future.delayed(Duration(milliseconds: 500));
      bool successful = await process.toggle();
      if (!successful) {
        // TODO: Notify of failure.
      }
    }
  }
}
