import 'package:flutter/material.dart';

import '../../logs/logging_manager.dart';

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  LoggingShortcutManager({required super.shortcuts});

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);

    if (result == KeyEventResult.handled) {
      log.i('''Handled shortcut
Shortcut: $event
Context: $context
      ''');
    }

    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    log.i('''
Action invoked:
Action: $action($intent)
From: $context
    ''');

    super.invokeAction(action, intent, context);

    return null;
  }
}
