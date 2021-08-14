import 'dart:ffi' as ffi;

import 'package:dynamic_load/dynamic_load.dart';
import 'package:ffi/ffi.dart';

import '_winternl.dart';

export '_winternl.dart';

final funcNtQuerySystemInformation = using((Arena arena) {
  final pNtQuerySystemInformation =
      getFuncAddress('ntdll.dll', 'NtQuerySystemInformation');

  return ffi.Pointer<
              ffi.NativeFunction<NativeNtQuerySystemInformation>>.fromAddress(
          pNtQuerySystemInformation)
      .asFunction<DartNtQuerySystemInformation>();
});
