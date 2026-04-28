import 'package:nyrna/updates/updates.dart';
import 'package:test/test.dart';

void main() {
  group('VersionInfo:', () {
    test('empty() factory has default/empty values', () {
      final info = VersionInfo.empty();
      expect(info.currentVersion, '');
      expect(info.latestVersion, isNull);
      expect(info.updateAvailable, false);
    });

    test('constructor stores provided values', () {
      const info = VersionInfo(
        currentVersion: '1.2.3',
        latestVersion: '1.3.0',
        updateAvailable: true,
      );
      expect(info.currentVersion, '1.2.3');
      expect(info.latestVersion, '1.3.0');
      expect(info.updateAvailable, true);
    });

    test('constructor with no update available', () {
      const info = VersionInfo(
        currentVersion: '2.0.0',
        latestVersion: '2.0.0',
        updateAvailable: false,
      );
      expect(info.currentVersion, '2.0.0');
      expect(info.latestVersion, '2.0.0');
      expect(info.updateAvailable, false);
    });
  });
}
