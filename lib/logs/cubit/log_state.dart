part of 'log_cubit.dart';

class LogState extends Equatable {
  /// The cumulative text of the logs.
  final String logsText;

  const LogState({
    required this.logsText,
  });

  const LogState.initial() : logsText = '';

  @override
  List<Object> get props => [logsText];

  LogState copyWith({
    String? logsText,
  }) {
    return LogState(
      logsText: logsText ?? this.logsText,
    );
  }
}
