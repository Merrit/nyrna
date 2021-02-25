import 'package:nyrna/window/window_controls.dart';

class Window {
  Window({this.title, this.pid, this.id})
      : _windowControls = WindowControlsProvider.getNativeControls();

  WindowControls _windowControls;

  String title;

  int pid;

  /// Unique window id from the hexadecimal integer.
  int id;

  Future<void> minimize() async => await _windowControls.minimize(id);

  Future<void> restore() async => await _windowControls.restore(id);
}
