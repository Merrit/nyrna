import 'package:equatable/equatable.dart';

import 'process/models/process.dart';

/// Friendly representation of a visible window.
class Window extends Equatable {
  /// The unique window ID number associated with this window.
  final int id;

  /// The process associated with this window.
  final Process process;

  /// The title of this window, often shown on the window's 'Title Bar'.
  ///
  /// Can & does change, for example a browser shows the title of the page.
  final String title;

  Window({
    required this.id,
    required this.process,
    required this.title,
  });

  @override
  List<Object> get props => [id, process, title];

  Window copyWith({
    int? id,
    Process? process,
    String? title,
  }) {
    return Window(
      id: id ?? this.id,
      process: process ?? this.process,
      title: title ?? this.title,
    );
  }
}
