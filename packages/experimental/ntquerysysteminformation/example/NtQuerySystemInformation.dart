// ignore_for_file: omit_local_variable_types, unused_local_variable

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ntdll/winternl.dart';
import 'ntstatus/ntstatus.dart';

///
/// https://github.com/Sunbreak/dynamic_load.trial/tree/develop
///

void main() {
  using((Arena arena) {
    final pNeedSize = arena<Uint32>();
    var status = funcNtQuerySystemInformation(
        SYSTEM_INFORMATION_CLASS.SystemProcessInformation,
        nullptr,
        0,
        pNeedSize);
    if (status != STATUS_INFO_LENGTH_MISMATCH) throw Exception('Unknown');

    final pBuffer = arena<Uint8>(pNeedSize.value);
    status = funcNtQuerySystemInformation(
        SYSTEM_INFORMATION_CLASS.SystemProcessInformation,
        pBuffer.cast(),
        pNeedSize.value,
        nullptr);
    if (status < 0) {
      throw Exception('Query SystemProcessInformation error: $status');
    }

    var address = pBuffer.address;
    var nextEntryOffset = 0;
    do {
      address += nextEntryOffset;
      final procRef =
          Pointer.fromAddress(address).cast<SYSTEM_PROCESS_INFORMATION>().ref;
      // print('UniqueProcessId: ${procRef.UniqueProcessId.address}');
      final namePtr = procRef.ImageName.Buffer.cast<Utf16>();
      String name = '';
      if (namePtr != nullptr) {
        final name = namePtr.toDartString();
        // print('Name: $name');
      }
      // print('NumberOfThreads: ${procRef.NumberOfThreads}\n');
      if (procRef.UniqueProcessId.address == 18228) {
        print('~~~~~~~~~~~~~~~~~~~~');
        print('This should be the Notepad process, with PID 18228.');
        print('Name: $name');
        print('UniqueProcessId: ${procRef.UniqueProcessId.address}');
        print('NumberOfThreads: ${procRef.NumberOfThreads}\n');
        for (var i = 0; i < (procRef.NumberOfThreads - 1); i++) {
          // ignore: todo
          /// TODO: If we could figure out how to get the [SYSTEM_THREAD_INFORMATION]
          /// from the array following the [SYSTEM_PROCESS_INFORMATION], we'd
          /// have everything necessary to do everything natively from dart.
          /// Frustrating without proper docs, but maybe look into it more later.
          /// Also, who knows if this would work on Windows 11?

          // final threadInfoAddress =
          //     procRef.NextEntryOffset + sizeOf<SYSTEM_PROCESS_INFORMATION>();
          // final threadInfo = Pointer.fromAddress(threadInfoAddress)
          //     .cast<SYSTEM_THREAD_INFORMATION>()
          //     .ref;
          // print(threadInfo);
        }
        print('~~~~~~~~~~~~~~~~~~~~');
      }
      nextEntryOffset = procRef.NextEntryOffset;
    } while (nextEntryOffset != 0);
  });
}
