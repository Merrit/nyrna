import 'dart:async';

import '../../typedefs.dart';
import '../../window.dart';
import '../linux.dart';
import 'active_window_wayland.dart';
import 'active_window_x11.dart';

/// Desktop and window manager agnostic interface to get the active window.
class ActiveWindowService {
  final Linux _linux;
  final RunFunction _run;

  ActiveWindowService(this._linux, this._run);

  /// Fetches the active window, which will be emitted by the [Linux] object.
  Future<void> fetch() async {
    switch (_linux.sessionType.displayProtocol) {
      case DisplayProtocol.wayland:
        await ActiveWindowWayland.fetch(_linux);
      case DisplayProtocol.x11:
        await ActiveWindowX11.fetch(_linux, _run);
      case DisplayProtocol.unknown:
        throw UnimplementedError('Unknown display protocol');
    }
  }

  /// Stream of the currently active window.
  final _activeWindowController = StreamController<Window>.broadcast();

  Stream<Window> get activeWindow => _activeWindowController.stream;
}
