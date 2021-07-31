import '../native_platform.dart';

/// Represents a visible window on the current desktop.
class Window {
  /// The unique window ID number associated with this window.
  final int id;

  /// The process associated with this window.
  Process? process;

  /// The title of this window, often shown on the window's 'Title Bar'.
  ///
  /// Can & does change, for example a browser shows the title of the page.
  final String title;

  Window({
    required this.id,
    this.process,
    required this.title,
  });
}
