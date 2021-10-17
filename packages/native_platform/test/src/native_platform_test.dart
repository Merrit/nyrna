import 'package:native_platform/src/native_platform.dart';
import 'package:test/test.dart';

void main() {
  final platform = NativePlatform();

  test('currentDesktop has a return value', () async {
    final desktop = await platform.currentDesktop();
    expect(desktop, isA<int>());
  });
}
