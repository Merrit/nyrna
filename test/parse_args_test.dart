import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/parse_args.dart';

void main() {
  group(
    'Toggle flag',
    () {
      setUp(() => Config.toggle = false);

      test(
        'With no flags toggle is false',
        () {
          parseArgs([]);
          expect(Config.toggle, false);
        },
      );
      test(
        '--toggle sets Config.toggle to true',
        () {
          parseArgs(['--toggle']);
          expect(Config.toggle, true);
        },
      );

      test(
        '-t sets Config.toggle to true',
        () {
          parseArgs(['-t']);
          expect(Config.toggle, true);
        },
      );

      test(
        'With unknown flag Config.toggle returns false',
        () {
          parseArgs(['--taco']);
          expect(Config.toggle, false);
        },
      );
    },
  );
}
