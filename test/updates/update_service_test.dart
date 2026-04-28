import 'package:nyrna/updates/update_service.dart';
import 'package:test/test.dart';

// Note: Full integration testing of UpdateService.getVersionInfo() requires
// dependency injection for http.Client and PackageInfo. The internal
// _getCurrentVersion() / _getLatestVersion() calls are not directly testable
// without further refactoring. This file tests the version-tag parsing logic
// that is exposed via @visibleForTesting.

void main() {
  late UpdateService service;

  setUp(() {
    service = UpdateService();
  });

  group('UpdateService.parseVersionTag():', () {
    test('strips leading v prefix', () {
      expect(service.parseVersionTag('v1.2.3'), '1.2.3');
    });

    test('leaves version unchanged when no leading v', () {
      expect(service.parseVersionTag('1.2.3'), '1.2.3');
    });

    test('strips pre-release suffix after hyphen', () {
      expect(service.parseVersionTag('v1.2.3-beta'), '1.2.3');
    });

    test('strips pre-release suffix with multiple parts', () {
      expect(service.parseVersionTag('v2.0.0-alpha.1'), '2.0.0');
    });

    test('handles major version only', () {
      expect(service.parseVersionTag('v3'), '3');
    });

    test('handles major.minor version', () {
      expect(service.parseVersionTag('v1.0'), '1.0');
    });

    test('handles four-part version', () {
      expect(service.parseVersionTag('v1.2.3.4'), '1.2.3.4');
    });
  });
}
