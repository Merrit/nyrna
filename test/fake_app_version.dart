import 'package:mocktail/mocktail.dart';
import 'package:nyrna/infrastructure/app_version/app_version.dart';

class FakeAppVersion extends Fake implements AppVersion {
  @override
  Future<String> latest() async => '1.0.0';

  @override
  String running() => '1.0.0';

  @override
  Future<bool> updateAvailable() async => false;
}
