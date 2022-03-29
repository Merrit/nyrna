import 'dart:ffi';

import 'package:dynamic_load/dynamic_load.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final bool kIsX64 = sizeOf<Pointer>() == 8;

// Inspired by https://github.com/timsneath/win32/blob/main/example/dynamic_load.dart
void main() {
  using((Arena arena) {
    final systemInfo = arena<SYSTEM_INFO>();
    final nativeSystemInfo = arena<SYSTEM_INFO>();

    GetSystemInfo(systemInfo);
    getNativeSystemInfo(nativeSystemInfo);

    if (kIsX64) {
      assert(systemInfo.ref.wProcessorArchitecture ==
          nativeSystemInfo.ref.wProcessorArchitecture);
    } else {
      // https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getnativesysteminfo
      assert(systemInfo.ref.wProcessorArchitecture !=
          nativeSystemInfo.ref.wProcessorArchitecture);
    }

    final archName = getArchitectureName(systemInfo.ref.wProcessorArchitecture);
    final nativeArchName =
        getArchitectureName(nativeSystemInfo.ref.wProcessorArchitecture);
    print('archName $archName, nativeArchName $nativeArchName');
  });
}

typedef getNativeSystemInfoNative = Void Function(
    Pointer<SYSTEM_INFO> lpSystemInfo);
typedef getNativeSystemInfoDart = void Function(
    Pointer<SYSTEM_INFO> lpSystemInfo);

void getNativeSystemInfo(Pointer<SYSTEM_INFO> lpSystemInfo) {
  final pGetNativeSystemInfo =
      getFuncAddress('kernel32.dll', 'GetNativeSystemInfo');

  final funcGetNativeSystemInfo =
      Pointer<NativeFunction<getNativeSystemInfoNative>>.fromAddress(
              pGetNativeSystemInfo)
          .asFunction<getNativeSystemInfoDart>();

  funcGetNativeSystemInfo(lpSystemInfo);
}

String getArchitectureName(int wProcessorArchitecture) {
  switch (wProcessorArchitecture) {
    case PROCESSOR_ARCHITECTURE_INTEL:
      return 'PROCESSOR_ARCHITECTURE_INTEL';
    case PROCESSOR_ARCHITECTURE_ARM:
      return 'PROCESSOR_ARCHITECTURE_ARM';
    case PROCESSOR_ARCHITECTURE_IA64:
      return 'PROCESSOR_ARCHITECTURE_IA64';
    case PROCESSOR_ARCHITECTURE_AMD64:
      return 'PROCESSOR_ARCHITECTURE_AMD64';
    case PROCESSOR_ARCHITECTURE_ARM64:
      return 'PROCESSOR_ARCHITECTURE_ARM64';
    default:
      throw Exception('Unknown architecture');
  }
}
