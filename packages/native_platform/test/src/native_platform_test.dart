import 'package:native_platform/src/native_platform.dart';
import 'package:test/test.dart';

import 'skip_github.dart';

void main() {
  final platform = NativePlatform();

  group('NativePlatform:', () {
    if (runningInCI) return;

    test('currentDesktop has a return value', () async {
      final desktop = await platform.currentDesktop();
      expect(desktop, isA<int>());
    });

    test('activeWindow returns a window', () async {
      final activeWindow = await platform.activeWindow();
      expect(activeWindow.id, isPositive);
      expect(activeWindow.process.pid, isPositive);
    });
  });
}
