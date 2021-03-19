import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/arguments/argument_parser.dart';

void main() {
  group(
    'Toggle flag',
    () {
      setUp(() => Config.toggle = false);

      test(
        'With no flags toggle is false',
        () {
          ArgumentParser([]);
          expect(Config.toggle, false);
        },
      );
      test(
        '--toggle sets Config.toggle to true',
        () {
          ArgumentParser(['--toggle']);
          expect(Config.toggle, true);
        },
      );

      test(
        '-t sets Config.toggle to true',
        () {
          ArgumentParser(['-t']);
          expect(Config.toggle, true);
        },
      );

      test(
        'With unknown flag Config.toggle returns false',
        () {
          ArgumentParser(['--taco']);
          expect(Config.toggle, false);
        },
      );
    },
  );
}
