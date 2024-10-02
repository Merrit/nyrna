// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'dart:ffi';

final _kernel32 = DynamicLibrary.open('kernel32.dll');

final CreateToolhelp32Snapshot =
    _kernel32.lookupFunction<IntPtr Function(Uint32, Uint32), int Function(int, int)>(
        'CreateToolhelp32Snapshot');

final Process32First = _kernel32.lookupFunction<
    Int32 Function(IntPtr hSnapshot, Pointer<PROCESSENTRY32> lppe),
    int Function(int hSnapshot, Pointer<PROCESSENTRY32> lppe)>('Process32First');

final Process32Next = _kernel32.lookupFunction<
    Int32 Function(IntPtr hSnapshot, Pointer<PROCESSENTRY32> lppe),
    int Function(int hSnapshot, Pointer<PROCESSENTRY32> lppe)>('Process32Next');

final class PROCESSENTRY32 extends Struct {
  @Int32()
  external int dwSize;
  @Int32()
  external int cntUsage;
  @Int32()
  external int th32ProcessID;
  external Pointer<Uint32> th32DefaultHeapID;
  @Int32()
  external int th32ModuleID;
  @Int32()
  external int cntThreads;
  @Int32()
  external int th32ParentProcessID;
  @Int32()
  external int pcPriClassBase;
  @Int32()
  external int dwFlags;
  @Array(260)
  external Array<Uint8> _szExeFile;
  String get szExeFile => _unwrap(_szExeFile);
}

String _unwrap(Array<Uint8> bytes) {
  String buf = "";
  int i = 0;
  while (bytes[i] != 0) {
    buf += utf8.decode([bytes[i]]);
    i += 1;
  }
  return buf;
}

const TH32CS_SNAPPROCESS = 0x00000002;
