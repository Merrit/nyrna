import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/infrastructure/logger/log_file.dart';

part 'log_state.dart';

late LogCubit logCubit;

class LogCubit extends Cubit<LogState> {
  LogCubit()
      : super(
          LogState(
            logLevel: Level.INFO,
            logsText: '',
          ),
        ) {
    logCubit = this;
    getLogsText(state.logLevel);
  }

  void getLogsText(Level level) {
    String logsText = '';
    LogFile.logs.forEach(
      (LogRecord record) {
        // Add if the record's level matches the user's choice.
        if (record.level == level || level == Level.ALL) {
          logsText = '${record.time} \n'
              '${record.level.name} \n'
              'Logger: ${record.loggerName} \n'
              '${record.message} \n'
              '\n';
        }
      },
    );
    emit(state.copyWith(
      logLevel: level,
      logsText: logsText,
    ));
  }
}
