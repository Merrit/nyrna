import 'dart:io';

import '../window.dart';

/// Linux specific window controls using `xdotool`.
class LinuxWindowControls implements WindowControls {
  @override
  Future<void> minimize(int? id) async {
    await Process.run(
      'xdotool',
      ['windowminimize', '$id', '--sync'],
    );
  }

  @override
  Future<void> restore(int? id) async {
    await Process.run(
      'xdotool',
      ['windowactivate', '$id', '--sync'],
    );
  }
}
