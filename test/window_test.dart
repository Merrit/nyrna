import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/window.dart';

void main() {
  test(
    'Can instantiate ActiveWindow',
    () {
      var activeWindow = ActiveWindow();
      expect(activeWindow.runtimeType, ActiveWindow);
    },
  );
  test(
    'ActiveWindow pid is not null',
    () {
      var activeWindow = ActiveWindow();
      print('Active window pid: ${activeWindow.pid}');
      expect(activeWindow.pid, isNot(null));
    },
  );
  test(
    'ActiveWindow id is not null',
    () {
      var activeWindow = ActiveWindow();
      print('Active window id: ${activeWindow.id}');
      expect(activeWindow.id, isNot(null));
    },
  );
}
