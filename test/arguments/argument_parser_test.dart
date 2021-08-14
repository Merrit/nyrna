import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/domain/arguments/argument_parser.dart';

void main() {
  test('With no flags log is false', () async {
    final parser = ArgumentParser([]);
    await parser.parse();
    expect(ArgumentParser.logToFile, false);
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
}
