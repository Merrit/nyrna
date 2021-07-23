import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';
import 'package:nyrna/window/active_window.dart';

Future<void> main() async {
  final settings = Preferences.instance;
  await settings.initialize();

  ActiveWindow? activeWindow;

  setUp(() async {
    activeWindow = ActiveWindow();
    await activeWindow!.initialize();
  });

  tearDown(() => activeWindow = null);

  test(
    'Can instantiate ActiveWindow',
    () {
      expect(activeWindow.runtimeType, ActiveWindow);
    },
  );
  test(
    'ActiveWindow pid is not null',
    () {
      print('Active window pid: ${activeWindow!.pid}');
      expect(activeWindow!.pid, isNot(null));
    },
  );
  test(
    'ActiveWindow id is not null',
    () {
      print('Active window id: ${activeWindow!.id}');
      expect(activeWindow!.id, isNot(null));
    },
  );
}
