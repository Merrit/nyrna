import 'package:mocktail/mocktail.dart';
import 'package:native_platform/native_platform.dart';

class MockProcess extends Mock implements Process {
  @override
  final int pid;

  @override
  final String executable;

  MockProcess({
    required this.pid,
    required this.executable,
  });
}
