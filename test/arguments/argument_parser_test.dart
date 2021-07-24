import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/domain/arguments/argument_parser.dart';

void main() {
  test('With no flags log is false', () async {
    final parser = ArgumentParser([]);
    await parser.parse();
    expect(parser.toggleFlagged, false);
  });

  test('Config.log is true with -l flag', () async {
    final parser = ArgumentParser(['-l']);
    await parser.parse();
    expect(ArgumentParser.logToFile, true);
  });

  test('Config.log is true with --log flag', () async {
    final parser = ArgumentParser(['--log']);
    await parser.parse();
    expect(ArgumentParser.logToFile, true);
  });

  test(
    'With no flags toggle is false',
    () async {
      final parser = ArgumentParser([]);
      await parser.parse();
      expect(parser.toggleFlagged, false);
    },
  );
  test(
    '--toggle sets Config.toggle to true',
    () async {
      final parser = ArgumentParser(['--toggle']);
      await parser.parse();
      expect(parser.toggleFlagged, true);
    },
  );

  test(
    '-t sets Config.toggle to true',
    () async {
      final parser = ArgumentParser(['-t']);
      await parser.parse();
      expect(parser.toggleFlagged, true);
    },
  );

  test(
    'With log and toggle flags log and toggle are true',
    () async {
      final parser = ArgumentParser(['-tl']);
      await parser.parse();
      expect(parser.toggleFlagged, true);
      expect(ArgumentParser.logToFile, true);
    },
  );
}
