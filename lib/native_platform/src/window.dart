import 'package:freezed_annotation/freezed_annotation.dart';

import 'process/models/process.dart';

part 'window.freezed.dart';

/// Represents a visible window.
@freezed
class Window with _$Window {
  const factory Window({
    /// The unique window ID number associated with this window.
    ///
    /// Can be either a number or a UUID (e.g. on KDE Wayland).
    required String id,

    /// The process associated with this window.
    required Process process,

    /// The title of this window, often shown on the window's 'Title Bar'.
    ///
    /// Can & does change, for example a browser shows the title of the page.
    required String title,
  }) = _Window;
}
