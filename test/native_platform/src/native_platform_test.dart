import 'dart:io' as io;

import 'package:nyrna/logs/logging_manager.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:test/test.dart';

import 'skip_github.dart';

Future<void> main() async {
  await LoggingManager.initialize(verbose: false);
  final platform = await NativePlatform.initialize();

  group('NativePlatform:', () {
    if (runningInCI) return;

    test('currentDesktop has a return value', () async {
      final desktop = await platform.currentDesktop();
      expect(desktop, isA<int>());
    });

    test('activeWindow returns a window', () async {
      // If system is Wayland, skip this test since it will fail.
      // Might be able to revisit once Wayland support is added.
      final sessionType = io.Platform.environment['XDG_SESSION_TYPE'];
      if (sessionType == 'wayland') {
        return;
      }

      final activeWindow = platform.activeWindow;
      await platform.checkActiveWindow();
      expect(activeWindow, isA<Window>());
      expect(activeWindow!.id, isPositive);
      expect(activeWindow.process.pid, isPositive);
    });
  });
}
