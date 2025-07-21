import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';

part 'loading_state.dart';
part 'loading_cubit.freezed.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final NativePlatform nativePlatform;

  LoadingCubit(this.nativePlatform) : super(const LoadingInitial()) {
    checkDependencies();
  }

  Future<void> checkDependencies() async {
    log.i('Checking dependencies..');

    final dependenciesSatisfied = await nativePlatform.checkDependencies();

    LoadingState newState;
    newState = (dependenciesSatisfied) //
        ? const LoadingSuccess()
        : const LoadingError(errorMsg: '''
Missing dependencies.

Please see the instructions at https://nyrna.merritt.codes/docs/linux-requirements and 
relaunch Nyrna after installing the dependencies.''');

    emit(newState);
  }
}
