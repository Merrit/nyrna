/// The portion of Nyrna that will act as a toggle to
/// suspend / resume the active, foreground window.
///
/// Calling this should be bound to a hotkey
/// using the operating system's default methods on Linux, or by using
/// the included `toggle_active_hotkey.exe` on Windows which sits in the
/// system tray and listens for the `Pause` keyboard key to activate.
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
library active_window;

export 'src/active_window_handler.dart';
export 'src/logger.dart';
export 'src/toggle_active_window.dart';
