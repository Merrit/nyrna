import 'dart:io' show ProcessResult, ProcessSignal;

/// Function that runs the `kill` command on the host system.
///
/// This typedef exists to facilitate dependency injection and testing.
///
/// Expected to be `Process.killPid()` from `dart:io` in production, and a mock
/// function in unit tests.
typedef KillFunction = bool Function(int pid, [ProcessSignal signal]);

/// Function that runs the given [executable] on the host system with [args].
///
/// This typedef exists to facilitate dependency injection and testing.
///
/// Expected to be `Process.run()` from `dart:io` in production, and a mock
/// function in unit tests.
typedef RunFunction = Future<ProcessResult> Function(
  String executable,
  List<String> args,
);
