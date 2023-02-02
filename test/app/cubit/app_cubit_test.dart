import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:test/test.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class MockStorageRepository extends Mock implements StorageRepository {}

class MockLaunchUrl extends Mock {
  Future<bool> call(
    Uri url, {
    url_launcher.LaunchMode mode,
    url_launcher.WebViewConfiguration webViewConfiguration,
    String? webOnlyWindowName,
  });
}

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  late StorageRepository storageRepository;
  late LaunchUrl urlLauncher;

  setUpAll(() async {
    registerFallbackValue(Uri());
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    storageRepository = MockStorageRepository();
    when(() => storageRepository.getValue(any())).thenAnswer((_) async => null);

    urlLauncher = MockLaunchUrl();
    when(() => urlLauncher.call(any())).thenAnswer((_) async => true);

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
        verify(() => urlLauncher.call(any())).called(1);
      });

      test('bad url returns false', () async {
        const badTestUrl = 'htp:/gogg.m';
        final uri = Uri.parse(badTestUrl);
        when(() => urlLauncher.call(uri))
            .thenThrow(PlatformException(code: 'bad url'));
        final result = await cubit.launchURL(badTestUrl);
        expect(result, false);
        verify(() => urlLauncher.call(any())).called(1);
      });
    });
  });
}
