import 'package:args/args.dart';
import 'package:nyrna/config.dart';

void parseArgs(List<String> args) {
  var parser = ArgParser();

  parser.addFlag(
    'toggle',
    abbr: 't',
    defaultsTo: false,
  );

  try {
    final results = parser.parse(args);
    final toggle = results.wasParsed('toggle');
    if (toggle) Config.toggle = true;
  } catch (e) {
    print(e);
  }
}
