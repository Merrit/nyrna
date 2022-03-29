import 'package:flutter_test/flutter_test.dart';
import 'package:nyrna/main.dart';

void main() {
  group('ArgumentParser:', () {
    var argParser = ArgumentParser();

    setUp(() => argParser = ArgumentParser());

    test('toggle defaults to false', () {
      final args = <String>[];
      argParser.parseArgs(args);
      expect(argParser.toggleActiveWindow, false);
    });

    test('--toggle works', () {
      final args = ['--toggle'];
      argParser.parseArgs(args);
      expect(argParser.toggleActiveWindow, true);
    });

    test('-t works', () {
      final args = ['-t'];
      argParser.parseArgs(args);
      expect(argParser.toggleActiveWindow, true);
    });

    test('log defaults to false', () {
      final args = <String>[];
      argParser.parseArgs(args);
      expect(argParser.logToFile, false);
    });

    test('--log works', () {
      final args = ['--log'];
      argParser.parseArgs(args);
      expect(argParser.logToFile, true);
    });

    test('-l works', () {
      final args = ['-l'];
      argParser.parseArgs(args);
      expect(argParser.logToFile, true);
    });
  });
}
