import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/nyrna.dart';

void main() {
  test('Desktop is not null', () async {
    var desktop = await Nyrna.currentDesktop;
    expect(desktop.runtimeType, int);
  });
}
