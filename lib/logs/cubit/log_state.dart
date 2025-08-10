part of 'log_cubit.dart';

@freezed
abstract class LogState with _$LogState {
  const factory LogState({
    /// The cumulative text of the logs.
    required String logsText,
  }) = _LogState;

  factory LogState.initial() => const LogState(logsText: '');
}
