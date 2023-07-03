import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<StorageRepository>(),
])
import 'app_cubit_test.mocks.dart';

MockStorageRepository mockStorageRepository = MockStorageRepository();

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockStorageRepository);

    cubit = AppCubit(
      mockStorageRepository,
    );
  });

  group('AppCubit:', () {
    test('firstRun default is true', () {
      // This test may require a delay if the cubit's init takes longer.
      expect(state.firstRun, true);
    });
  });
}
