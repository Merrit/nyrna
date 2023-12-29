/// The portion of Nyrna that will act as a toggle to
/// suspend / resume the active, foreground window.
///
/// Calling this should be bound to a hotkey
///
/// When the hotkey launches Nyrna with the `--toggle` argument it will:
/// - Find the active, foreground window
/// - Minimize the window
/// - Suspend the process that owns the window
/// - Save the PID of said process & window id to a file
///
/// On subsequent launch when the file with a saved PID is found:
/// - Resume the suspended process
/// - Restore / unminimize the associated window
/// - Delete the file containing the PID & window id so next call will suspend.
library;

export 'src/active_window.dart';
