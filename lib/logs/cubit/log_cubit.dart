import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../logs.dart';

part 'log_state.dart';
part 'log_cubit.freezed.dart';

late LogCubit logCubit;

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogState.initial()) {
    logCubit = this;
    getLogsText();
  }

  Future<void> getLogsText() async {
    final logs = await LoggingManager.instance.getLogs();
    emit(state.copyWith(logsText: logs));
  }
}
