import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nyrna/main.dart' as app;
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'nyrna_test',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  group('Integration Tests:', () {
    testWidgets('main screen loads', (tester) async {
      await app.main([]);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
