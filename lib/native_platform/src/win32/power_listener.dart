import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../../../logs/logs.dart';

const _deviceNotifyCallback = 2;

const _pbtApmSuspend = 0x4;
const _pbtApmResumeSuspend = 0x7;
const _pbtApmResumeStandby = 0x8;
const _pbtApmResumeAutomatic = 0x12;

typedef _RegisterNative =
    Uint32 Function(Uint32, Pointer<Void>, Pointer<Pointer<Void>>);
typedef _RegisterDart =
    int Function(int, Pointer<Void>, Pointer<Pointer<Void>>);
typedef _UnregisterNative = Uint32 Function(Pointer<Void>);
typedef _UnregisterDart = int Function(Pointer<Void>);

/// Notifies when the system is about to sleep and when it has woken up.
///
/// Used to resume suspended processes before the system sleeps, as a process
/// that is frozen across a power transition can misbehave when it wakes.
class PowerListener {
  final void Function() onSuspend;
  final void Function() onResume;

  late final NativeCallable<Void Function(Pointer<Void>, Uint32, Pointer<Void>)>
  _callback;
  late final Pointer<Pointer<Void>> _params;
  late final Pointer<Pointer<Void>> _registration;
  late final _UnregisterDart _unregister;

  PowerListener({required this.onSuspend, required this.onResume}) {
    final powrprof = DynamicLibrary.open('powrprof.dll');
    final register = powrprof.lookupFunction<_RegisterNative, _RegisterDart>(
      'PowerRegisterSuspendResumeNotification',
    );
    _unregister = powrprof.lookupFunction<_UnregisterNative, _UnregisterDart>(
      'PowerUnregisterSuspendResumeNotification',
    );

    // The callback is invoked on a system thread, so it must be a listener,
    // which posts the call back onto this isolate.
    _callback =
        NativeCallable<
          Void Function(Pointer<Void>, Uint32, Pointer<Void>)
        >.listener(_handle);

    // DEVICE_NOTIFY_SUBSCRIBE_PARAMETERS { Callback; Context; }
    _params = calloc<Pointer<Void>>(2);
    _params[0] = _callback.nativeFunction.cast<Void>();
    _params[1] = nullptr;

    _registration = calloc<Pointer<Void>>();
    final result = register(
      _deviceNotifyCallback,
      _params.cast<Void>(),
      _registration,
    );

    if (result == 0) {
      log.i('Registered for system suspend/resume notifications.');
    } else {
      log.e('Failed to register for power notifications, error: $result');
    }
  }

  void _handle(Pointer<Void> context, int type, Pointer<Void> setting) {
    log.i('Power event received: 0x${type.toRadixString(16)}');

    switch (type) {
      case _pbtApmSuspend:
        onSuspend();
      case _pbtApmResumeSuspend:
      case _pbtApmResumeStandby:
      case _pbtApmResumeAutomatic:
        onResume();
    }
  }

  void dispose() {
    if (_registration.value != nullptr) _unregister(_registration.value);
    _callback.close();
    calloc.free(_params);
    calloc.free(_registration);
  }
}
