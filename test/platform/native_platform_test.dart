import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/platform/native_platform.dart';

void main() {
  NativePlatform nativePlatform;

  setUp(() => nativePlatform = NativePlatform());
  tearDown(() => nativePlatform = null);

  test('Can instantiate NativePlatform', () {
    expect(nativePlatform, isA<NativePlatform>());
  });

  test('currentDesktop is not null', () async {
    var currentDesktop = await nativePlatform.currentDesktop;
    print('currentDesktop: $currentDesktop');
    expect(currentDesktop, isNotNull);
  });

  test('windows getter is not empty', () async {
    var windows = await nativePlatform.windows;
    print('windows found: ${windows.length}');
    expect(windows, isNotEmpty);
  });

  test(
    'activeWindowPid is not null',
    () async {
      var pid = await nativePlatform.activeWindowPid;
      print('Active window pid: $pid');
      expect(pid, isNot(null));
    },
  );
  test(
    'activeWindowId is not null',
    () async {
      var id = await nativePlatform.activeWindowId;
      print('Active window id: $id');
      expect(id, isNot(null));
    },
  );

  test('checkDependencies is not null', () async {
    var haveDependencies = await nativePlatform.checkDependencies();
    print('haveDependencies: $haveDependencies');
    expect(haveDependencies, isA<bool>());
  });
}
