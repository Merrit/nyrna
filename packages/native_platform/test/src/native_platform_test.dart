import 'dart:io' show Platform;

import 'package:native_platform/src/native_platform.dart';
import 'package:test/test.dart';

void main() {
  final environmentVariables = Platform.environment;

  /// Tests that require a display & windows to work with will
  /// check for [runningInCI], and skip runs in GitHub Workflows.
  final bool runningInCI = (environmentVariables['GITHUB_ACTIONS'] == 'true');

  final platform = NativePlatform();

  test('currentDesktop has a return value', () async {
    final desktop = await platform.currentDesktop();
    expect(desktop, isA<int>());
  });

  test('activeWindow returns a window', () async {
    if (runningInCI) return;
    final activeWindow = await platform.activeWindow();
    expect(activeWindow.id, isPositive);
    expect(activeWindow.pid, isPositive);
  });
}
