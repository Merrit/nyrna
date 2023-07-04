import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../logs/logs.dart';
import '../../native_platform/native_platform.dart';
import '../../native_platform/src/linux/linux.dart';

part 'loading_state.dart';
part 'loading_cubit.freezed.dart';

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

      final unknownSessionMsg = '''
Unable to determine session type. The XDG_SESSION_TYPE environment variable is set to "$sessionType".
Please note that Wayland is not currently supported.''';

      const waylandNotSupportedMsg = '''
Wayland is not currently supported.

[Sign in using X11 instead](https://docs.fedoraproject.org/en-US/quick-docs/configuring-xorg-as-default-gnome-session/).''';

      switch (sessionType) {
        case 'wayland':
          emit(const LoadingError(errorMsg: waylandNotSupportedMsg));
          return;
        case 'x11':
          break;
        default:
          log.e(unknownSessionMsg);
      }
    }

    final dependenciesSatisfied = await nativePlatform.checkDependencies();

    LoadingState newState;
    newState = (dependenciesSatisfied) //
        ? const LoadingSuccess()
        : const LoadingError(errorMsg: '''
Dependency check failed.

Install the dependencies from your system's package manager:

- `xdotool`
- `wmctrl`''');

    emit(newState);
  }
}
