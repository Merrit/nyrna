import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/globals.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/settings/update_notifier.dart';

void main() {
  Settings? _settings;

  setUp(() async {
    _settings = Settings.instance;
    await _settings!.initialize();
  });

  tearDown(() {
    _settings = null;
  });

  test('Current version being old returns true', () async {
    Globals.version = '1.0';
    final updateAvailable = await UpdateNotifier().updateAvailable();
    expect(updateAvailable, true);
  });

  test('Current version matching latest returns false', () async {
    final notifier = UpdateNotifier();
    Globals.version = await notifier.latestVersion();
    final updateAvailable = await notifier.updateAvailable();
    expect(updateAvailable, false);
  });
}
