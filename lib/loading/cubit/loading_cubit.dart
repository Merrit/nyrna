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
      switch (sessionType) {
        case 'wayland':
          emit(const LoadingWaylandError());
          return;
        case 'x11':
          break;
        default:
          log.e('''
Unable to determine session type. The XDG_SESSION_TYPE environment variable is set to "$sessionType".
Please note that Wayland is not currently supported.''');
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
