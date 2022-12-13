import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/url_launcher/url_launcher.dart';
import 'package:test/test.dart';

class MockStorageRepository extends Mock implements StorageRepository {}

class MockUrlLauncher extends Mock implements UrlLauncher {}

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  late StorageRepository storageRepository;
  late UrlLauncher urlLauncher;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    storageRepository = MockStorageRepository();
    when(() => storageRepository.getValue(any())).thenAnswer((_) async => null);

    urlLauncher = MockUrlLauncher();
    when(() => urlLauncher.canLaunch(any())).thenAnswer((_) async => true);
    when(() => urlLauncher.launch(any())).thenAnswer((_) async => true);

    cubit = AppCubit(
      storageRepository,
      urlLauncher,
    );
  });

  group('AppCubit:', () {
    test('firstRun default is true', () {
      // This test may require a delay if the cubit's init takes longer.
      expect(state.firstRun, true);
    });

    group('launchURL:', () {
      const correctTestUrl = 'https://www.google.com/';

      test('launches a correct url', () async {
        final result = await cubit.launchURL(correctTestUrl);
        expect(result, true);
        verify(() => urlLauncher.canLaunch(any())).called(1);
        verify(() => urlLauncher.launch(any())).called(1);
      });

      test('bad url returns false', () async {
        const badTestUrl = 'htp:/gogg.m';
        when(() => urlLauncher.canLaunch(Uri.parse(badTestUrl)))
            .thenAnswer((_) async => false);
        final result = await cubit.launchURL(badTestUrl);
        expect(result, false);
        verify(() => urlLauncher.canLaunch(any())).called(1);
        verifyNever(() => urlLauncher.launch(any()));
      });
    });
  });
}
