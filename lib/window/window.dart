import 'package:nyrna/window/window_controls.dart';

/// Represents a visible window on the current desktop.
class Window {
  Window({this.id, this.pid, this.title});

  final _windowControls = WindowControls();

  /// The unique window ID number associated with this window.
  final int id;

  /// The PID of the process associated with this window.
  final int pid;

  /// The title of this window, often shown on the window's 'Title Bar'.
  ///
  /// Can & does change, for example a browser shows the title of the page.
  final String title;

  /// Minimize this window.
  Future<void> minimize() async => await _windowControls.minimize(id);

  /// Restore (un-minimize) this window.
  Future<void> restore() async => await _windowControls.restore(id);
}
