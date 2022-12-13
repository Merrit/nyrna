import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app/app.dart';
import 'package:nyrna/url_launcher/url_launcher.dart';
import 'package:test/test.dart';

class MockUrlLauncher extends Mock implements UrlLauncher {}

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  late UrlLauncher urlLauncher;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    urlLauncher = MockUrlLauncher();
    when(() => urlLauncher.canLaunch(any())).thenAnswer((_) async => true);
    when(() => urlLauncher.launch(any())).thenAnswer((_) async => true);

    cubit = AppCubit(
      urlLauncher,
    );
  });

  group('AppCubit:', () {
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
