import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app_version/app_version.dart';

class MockAppVersion extends Mock implements AppVersion {
  @override
  String running() => '1.0.0';
}
