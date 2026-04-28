import 'dart:async';

import 'package:nyrna/logs/logs.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  group('LogCubit:', () {
    test('initial state has empty logsText', () {
      // LogCubit fires getLogsText() asynchronously from its constructor.
      // Accessing state synchronously after construction sees the initial value.
      //
      // NOTE: In the test environment, LoggingManager is backed by File('')
      // which causes getLogsText() to throw a PathNotFoundException
      // asynchronously.  Full testing requires refactoring LogCubit to inject
      // LoggingManager via DI rather than using the static singleton.
      late LogCubit cubit;
      runZonedGuarded(
        () {
          cubit = LogCubit();
        },
        (_, _) {
          // Suppress the unhandled PathNotFoundException from getLogsText()
          // that is fired unawaited in the constructor when running in the
          // test environment.
        },
      );

      expect(cubit.state, equals(LogState.initial()));
      expect(cubit.state.logsText, isEmpty);
    });

    test('LogState.initial() has empty logsText', () {
      final state = LogState.initial();
      expect(state.logsText, isEmpty);
    });

    test('LogState copyWith updates logsText', () {
      const updated = 'new log content';
      final state = LogState.initial().copyWith(logsText: updated);
      expect(state.logsText, updated);
    });
  });
}
