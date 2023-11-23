import 'package:helpers/helpers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/system_tray/system_tray.dart';
import 'package:nyrna/updates/updates.dart';
import 'package:nyrna/window/app_window.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AppWindow>(),
  MockSpec<NativePlatform>(),
  MockSpec<ReleaseNotesService>(),
  MockSpec<StorageRepository>(),
  MockSpec<SystemTrayManager>(),
  MockSpec<UpdateService>(),
])
import 'app_cubit_test.mocks.dart';

final mockAppWindow = MockAppWindow();
final mockNativePlatform = MockNativePlatform();
final mockReleaseNotesService = MockReleaseNotesService();
final mockStorageRepo = MockStorageRepository();
final mockSystemTrayManager = MockSystemTrayManager();
final mockUpdateService = MockUpdateService();

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockAppWindow);
    reset(mockNativePlatform);
    reset(mockReleaseNotesService);
    reset(mockStorageRepo);
    reset(mockSystemTrayManager);
    reset(mockUpdateService);

    when(mockUpdateService.getVersionInfo())
        .thenAnswer((_) async => VersionInfo.empty());

    cubit = AppCubit(
      mockAppWindow,
      mockNativePlatform,
      mockReleaseNotesService,
      mockStorageRepo,
      mockSystemTrayManager,
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
