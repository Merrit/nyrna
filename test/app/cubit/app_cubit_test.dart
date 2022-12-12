import 'package:mocktail/mocktail.dart';
import 'package:nyrna/app/app.dart';
import 'package:test/test.dart';
import 'package:url_launcher/url_launcher.dart';

class MockCanLaunchUrl extends Mock {
  Future<bool> call(Uri url);
}

late CanLaunchUrlFunction mockCanLaunchUrl;

class MockLaunchUrl extends Mock {
  Future<bool> call(
    Uri url, {
    LaunchMode mode,
    WebViewConfiguration webViewConfiguration,
    String? webOnlyWindowName,
  });
}

late LaunchUrlFunction mockLaunchUrl;

late AppCubit cubit;
AppState get state => cubit.state;

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockCanLaunchUrl = MockCanLaunchUrl();
    when(() => mockCanLaunchUrl(any())).thenAnswer((_) async => true);
    mockLaunchUrl = MockLaunchUrl();
    when(() => mockLaunchUrl(any())).thenAnswer((_) async => true);

    cubit = AppCubit(
      mockCanLaunchUrl,
      mockLaunchUrl,
    );
  });

  group('AppCubit:', () {
    group('launchURL:', () {
      const correctTestUrl = 'https://www.google.com/';

      test('launches a correct url', () async {
        final result = await cubit.launchURL(correctTestUrl);
        expect(result, true);
        verify(() => mockCanLaunchUrl(any())).called(1);
        verify(() => mockLaunchUrl(any())).called(1);
      });

      test('bad url returns false', () async {
        const badTestUrl = 'htp:/gogg.m';
        when(() => mockCanLaunchUrl(Uri.parse(badTestUrl)))
            .thenAnswer((_) async => false);
        final result = await cubit.launchURL(badTestUrl);
        expect(result, false);
        verify(() => mockCanLaunchUrl(any())).called(1);
        verifyNever(() => mockLaunchUrl(any()));
      });
    });
  });
}
