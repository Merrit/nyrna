import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/config.dart';
import 'package:nyrna/arguments/argument_parser.dart';

void main() {
  setUp(() {
    Config.log = false;
    Config.toggle = false;
  });

  test('With no flags log is false', () async {
    final parser = ArgumentParser([]);
    await parser.init();
    expect(Config.log, false);
  });

  test('Config.log is true with -l flag', () async {
    final parser = ArgumentParser(['-l']);
    await parser.init();
    expect(Config.log, true);
  });

  test('Config.log is true with --log flag', () async {
    final parser = ArgumentParser(['--log']);
    await parser.init();
    expect(Config.log, true);
  });

  test(
    'With no flags toggle is false',
    () async {
      final parser = ArgumentParser([]);
      await parser.init();
      expect(Config.toggle, false);
    },
  );
  test(
    '--toggle sets Config.toggle to true',
    () async {
      final parser = ArgumentParser(['--toggle']);
      await parser.init();
      expect(Config.toggle, true);
    },
  );

  test(
    '-t sets Config.toggle to true',
    () async {
      final parser = ArgumentParser(['-t']);
      await parser.init();
      expect(Config.toggle, true);
    },
  );

  test(
    'With log and toggle flags log and toggle are true',
    () async {
      final parser = ArgumentParser(['-tl']);
      await parser.init();
      expect(Config.toggle, true);
      expect(Config.log, true);
    },
  );
}
