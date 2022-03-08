import 'package:mocktail/mocktail.dart';
import 'package:nyrna/infrastructure/versions/versions.dart';

class FakeVersions extends Fake implements Versions {
  @override
  Future<String> latestVersion() async => '1.0.0';

  @override
  Future<String> runningVersion() async => '1.0.0';

  @override
  Future<bool> updateAvailable() async => false;
}
