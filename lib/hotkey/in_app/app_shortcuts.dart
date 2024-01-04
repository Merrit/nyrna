import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../logs/logging_manager.dart';
import 'shortcuts_manager.dart';

/// Shortcuts that are available everywhere in the app.
///
/// This widget is to be wrapped around the widget intended as a route,
/// or the entire MaterialApp.
class AppShortcuts extends StatelessWidget {
  final Widget child;

  AppShortcuts({
    super.key,
    required this.child,
  });

  final _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(
      LogicalKeyboardKey.keyQ,
      control: true,
    ): const QuitIntent(),
  };

  final _actions = <Type, Action<Intent>>{
    QuitIntent: QuitAction(),
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      manager: LoggingShortcutManager(shortcuts: _shortcuts),
      child: Actions(
        dispatcher: LoggingActionDispatcher(),
        actions: _actions,
        child: child,
      ),
    );
  }
}

/// An intent that is bound to QuitAction in order to quit this application.
class QuitIntent extends Intent {
  const QuitIntent();
}

/// An action that is bound to QuitIntent in order to quit this application.
class QuitAction extends Action<QuitIntent> {
  @override
  Object? invoke(QuitIntent intent) {
    log.i('Quit requested, exiting.');
    exit(0);
  }
}
