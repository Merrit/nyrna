import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../native_platform/src/linux/linux.dart';

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final NativePlatform nativePlatform;

  LoadingCubit()
      : nativePlatform = NativePlatform(),
        super(const LoadingInitial()) {
    checkDependencies();
  }

  Future<void> checkDependencies() async {
    log.v('Checking dependencies..');

    // Make sure we are not running under Wayland.
    if (Platform.isLinux) {
      final sessionType = await (nativePlatform as Linux).sessionType();
      if (sessionType != 'x11') {
        emit(const LoadingWaylandError());
        return;
      }
    }

    final dependenciesSatisfied = await nativePlatform.checkDependencies();

    LoadingState newState;
    newState = (dependenciesSatisfied) //
        ? const LoadingSuccess()
        : const LoadingDependencyError();

    emit(newState);
  }
}
