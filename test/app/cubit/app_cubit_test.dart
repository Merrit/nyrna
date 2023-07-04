import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/updates/updates.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<ReleaseNotesService>(),
  MockSpec<StorageRepository>(),
  MockSpec<UpdateService>(),
])
import 'app_cubit_test.mocks.dart';

final mockReleaseNotesService = MockReleaseNotesService();
final mockStorageRepo = MockStorageRepository();
final mockUpdateService = MockUpdateService();

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockReleaseNotesService);
    reset(mockStorageRepo);
    reset(mockUpdateService);

    when(mockUpdateService.getVersionInfo())
        .thenAnswer((_) async => VersionInfo.empty());

    cubit = AppCubit(
      mockReleaseNotesService,
      mockStorageRepo,
      mockUpdateService,
    );
  });

  group('AppCubit:', () {
    test('firstRun default is true', () {
      // This test may require a delay if the cubit's init takes longer.
      expect(state.firstRun, true);
    });
  });
}
