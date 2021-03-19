import 'package:args/args.dart';
import 'package:nyrna/config.dart';

class ArgumentParser {
  ArgumentParser(this.args) {
    _init();
  }

  final List<String> args;

  final _parser = ArgParser();

  void _init() {
    _setToggleFlag();
    _setLoggerFlag();
  }

  void _setToggleFlag() {
    _parser.addFlag(
      'toggle',
      abbr: 't',
      defaultsTo: false,
    );
    try {
      final results = _parser.parse(args);
      final toggle = results.wasParsed('toggle');
      if (toggle) Config.toggle = true;
    } catch (e) {
      print('Error parsing toggle flag: \n$e');
    }
  }

  void _setLoggerFlag() {
    _parser.addFlag(
      'log',
      abbr: 'l',
      defaultsTo: false,
    );
    try {
      final results = _parser.parse(args);
      final logger = results.wasParsed('log');
      if (logger) Config.log = true;
    } catch (e) {
      print('Error parsing logger flag: \n$e');
    }
  }
}
