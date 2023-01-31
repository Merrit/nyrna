import 'package:nyrna/argument_parser/argument_parser.dart';
import 'package:test/test.dart';

void main() {
  late ArgumentParser argParser;

  setUp(() {
    argParser = ArgumentParser();
  });

  group('ArgumentParser', () {
    test('singleton instance is accessible', () {
      expect(ArgumentParser.instance, isNotNull);
    });

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
