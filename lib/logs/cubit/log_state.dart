part of 'log_cubit.dart';

class LogState extends Equatable {
  /// The level of logs to show, changed with the DropdownButton.
  final Level logLevel;

  final String logsText;

  const LogState({
    required this.logLevel,
    required this.logsText,
  });

  @override
  List<Object> get props => [logLevel, logsText];

  LogState copyWith({
    Level? logLevel,
    String? logsText,
  }) {
    return LogState(
      logLevel: logLevel ?? this.logLevel,
      logsText: logsText ?? this.logsText,
    );
  }
}
