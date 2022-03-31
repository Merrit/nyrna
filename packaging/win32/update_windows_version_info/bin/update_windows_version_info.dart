import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Updates the `Runner.rc` file for the Windows build so it has the correct
/// version information. (windows/runner/Runner.rc)
///
/// Expects 2 arguments, the full paths for the pubspec & the Runner.rc
Future<void> main(List<String> args) async {
  final pubspecPath = args[0];
  final pubspecFile = File(pubspecPath);
  final YamlMap pubspecYaml = loadYaml(await pubspecFile.readAsString());
  final String version = pubspecYaml['version'];
  final semVer = Version.parse(version);

  final runnerRcPath = args[1];
  final runnerRcFile = File(runnerRcPath);
  String runnerRc = await runnerRcFile.readAsString();
  runnerRc = runnerRc
      .replaceAll(
        RegExp(r'(?<=#define VERSION_AS_NUMBER )\d.*'),
        '${semVer.major},${semVer.minor},${semVer.patch}',
      )
      .replaceAll(
        RegExp(r'(?<=#define VERSION_AS_STRING ")\d.*(?=")'),
        version,
      );

  await runnerRcFile.writeAsString(runnerRc);
}
