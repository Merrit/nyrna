import 'package:nyrna/main.dart';
import 'package:test/test.dart';

late ArgumentParser argParser;

void main() {
  setUp(() {
    argParser = ArgumentParser();
  });

  group('ArgumentParser', () {
    test('has expected values when given no arguments', () {
      expect(argParser.minimize, isNull);
      expect(argParser.toggleActiveWindow, isFalse);
      expect(argParser.verbose, isFalse);
    });

    test('parses arguments', () {
      argParser.parseArgs(['--no-minimize']);
      expect(argParser.minimize, isFalse);
    });

    test('parses multiple arguments', () {
      argParser.parseArgs(['--no-minimize', '--verbose']);
      expect(argParser.minimize, isFalse);
      expect(argParser.verbose, isTrue);
    });

    test('parses --toggle correctly', () {
      argParser.parseArgs(['--toggle']);
      expect(argParser.toggleActiveWindow, isTrue);
    });

    test('parses -t correctly', () {
      argParser.parseArgs(['-t']);
      expect(argParser.toggleActiveWindow, isTrue);
    });
  });
}
