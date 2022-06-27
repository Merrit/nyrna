import 'dart:io';

import 'package:window_size/window_size.dart';

class NyrnaWindow {
  const NyrnaWindow();

  void close() => exit(0);
  void hide() => setWindowVisibility(visible: false);
  void show() => setWindowVisibility(visible: true);
}
