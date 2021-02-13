import 'package:args/args.dart';
import 'package:nyrna/config.dart';

Future<void> parseArgs(List<String> args) {
  var parser = ArgParser();

  parser.addFlag(
    'toggle',
    abbr: 't',
    defaultsTo: false,
  );

  try {
    ArgResults results = parser.parse(args);
    bool toggle = results.wasParsed('toggle');
    if (toggle) Config.toggle = true;
  } catch (e) {
    print(e);
  }

  return null;
}
