import 'dart:io';

import '../../../logs/logs.dart';
import '../typedefs.dart';

/// Run commands from within a Flatpak environment, directly on the host.
RunFunction flatpakRun = (String executable, List<String> args) async {
  log.i('''
Running command from flatpak; using flatpakRun..
executable: $executable
args: $args''');

  final result = await Process.run(
    'flatpak-spawn',
    ['--host', executable, ...args],
  );

  final error = result.stderr.toString().trim();

  if (error != '') {
    log.e('Issue running command through flatpak-spawn: $error');
  }

  return result;
};

/// When in Flatpak using the built-in Process.killPid will try to act on the
/// dummy pids it sees inside the container, so we use the host run instead.
KillFunction flatpakKill = (
  int pid, [
  ProcessSignal signal = ProcessSignal.sigcont,
]) {
  flatpakRun('kill', ['-${signal.toString()}', '$pid']);
  return true;
};
