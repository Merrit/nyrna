import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app_version/app_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:test/test.dart';

class MockPackageInfo extends Mock implements PackageInfo {}

final packageInfo = MockPackageInfo();

AppVersion appVersion = AppVersion(packageInfo);

void main() {
  setUp(() {
    appVersion = AppVersion(packageInfo);
  });

  group('AppVersion:', () {
    group('parseVersionTag:', () {
      test('parses versions with 1 digit in each place', () {
        final version = appVersion.parseVersionTag('v1.2.3');
        expect(version, '1.2.3');
      });

      test('parses versions with 2 digits in each place', () {
        final version = appVersion.parseVersionTag('v12.23.34');
        expect(version, '12.23.34');
      });

      test('parses versions with 3 digits in each place', () {
        final version = appVersion.parseVersionTag('v123.234.345');
        expect(version, '123.234.345');
      });

      test('parses versions with 1 digit in each place and a postfix', () {
        final version = appVersion.parseVersionTag('v1.2.3-beta');
        expect(version, '1.2.3');
      });

      test('parses versions with 2 digits in each place and a postfix', () {
        final version = appVersion.parseVersionTag('v12.23.34-beta');
        expect(version, '12.23.34');
      });

      test('parses versions with 3 digits in each place and a postfix', () {
        final version = appVersion.parseVersionTag('v123.234.345-beta');
        expect(version, '123.234.345');
      });
    });
  });
}
