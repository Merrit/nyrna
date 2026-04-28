import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/loading/loading.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[MockSpec<NativePlatform>()])
import 'loading_cubit_test.mocks.dart';

final mockNativePlatform = MockNativePlatform();

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockNativePlatform);
  });

  group('LoadingCubit:', () {
    test('initial state is LoadingInitial', () {
      when(
        mockNativePlatform.checkDependencies(),
      ).thenAnswer((_) async => true);

      final cubit = LoadingCubit(mockNativePlatform);
      expect(cubit.state, isA<LoadingInitial>());
    });

    test('emits LoadingSuccess when dependencies are satisfied', () async {
      when(
        mockNativePlatform.checkDependencies(),
      ).thenAnswer((_) async => true);

      final cubit = LoadingCubit(mockNativePlatform);
      await cubit.checkDependencies();

      expect(cubit.state, isA<LoadingSuccess>());
    });

    test('emits LoadingError when dependencies are not satisfied', () async {
      when(
        mockNativePlatform.checkDependencies(),
      ).thenAnswer((_) async => false);

      final cubit = LoadingCubit(mockNativePlatform);
      await cubit.checkDependencies();

      expect(cubit.state, isA<LoadingError>());
      final errorState = cubit.state as LoadingError;
      expect(errorState.errorMsg, isNotEmpty);
    });
  });
}
