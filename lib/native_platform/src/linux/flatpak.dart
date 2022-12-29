import 'dart:io';

import '../typedefs.dart';

/// Run commands from within a Flatpak environment, directly on the host.
RunFunction flatpakRun = (String executable, List<String> args) async {
  return await Process.run(
    'flatpak-spawn',
    ['--host', executable, ...args],
  );
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

/// True if the application is running inside a Flatpak container.
final bool runningInFlatpak = Platform.environment.containsKey('FLATPAK_ID');
