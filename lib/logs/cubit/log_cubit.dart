import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logs.dart';

part 'log_state.dart';

late LogCubit logCubit;

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(const LogState.initial()) {
    logCubit = this;
    getLogsText();
  }

  Future<void> getLogsText() async {
    final logs = await LoggingManager.instance.getLogs();
    emit(state.copyWith(logsText: logs));
  }
}
