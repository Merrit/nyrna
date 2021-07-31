import 'package:collection/collection.dart';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/domain/native_platform/native_platform.dart';
import 'package:nyrna/infrastructure/native_platform/native_platform.dart';

part 'window_state.dart';

enum ToggleError {
  None,
  Suspend,
  Resume,
}

class WindowCubit extends Cubit<WindowState> {
  final AppCubit _appCubit;
  final NativePlatform _nativePlatform;
  final Window _window;

  WindowCubit({
    required AppCubit appCubit,
    required NativePlatform nativePlatform,
    required Window window,
  })  : _appCubit = appCubit,
        _nativePlatform = nativePlatform,
        _window = window,
        super(
          WindowState(
            executable: window.process?.executable ?? '',
            pid: window.process?.pid ?? 0,
            processStatus: window.process?.status ?? ProcessStatus.unknown,
            title: window.title,
            toggleError: ToggleError.None,
          ),
        ) {
    _initialize();
  }

  Future<void> _initialize() async {
    _listen();
  }

  void _listen() {
    _appCubit.stream.listen((event) {
      final window = event.windows.firstWhereOrNull((e) => e.id == _window.id);
      if (window != null) {
        emit(state.copyWith(
          processStatus: window.process?.status,
          title: window.title,
        ));
      } else {
        close();
      }
    });
  }

  /// Toggle suspend / resume for the process associated with the given window.
  Future<void> toggle() async {
    if (state.processStatus == ProcessStatus.suspended) {
      await _resume();
    } else {
      await _suspend();
    }
  }

  Future<void> _resume() async {
    final nativeProcess = NativeProcess(state.pid);
    final successful = await nativeProcess.resume();
    if (!successful) emit(state.copyWith(toggleError: ToggleError.Resume));
    // Restore the window _after_ resuming or it might not restore.
    await _nativePlatform.restoreWindow(_window.id);
  }

  Future<void> _suspend() async {
    // Minimize the window before suspending or it might not minimize.
    await _nativePlatform.minimizeWindow(_window.id);
    // Small delay on Win32 to ensure the window actually minimizes.
    // Doesn't seem to be necessary on Linux.
    if (io.Platform.isWindows) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    final nativeProcess = NativeProcess(state.pid);
    final successful = await nativeProcess.suspend();
    if (!successful) emit(state.copyWith(toggleError: ToggleError.Suspend));
    await _appCubit.fetchData();
  }
}
