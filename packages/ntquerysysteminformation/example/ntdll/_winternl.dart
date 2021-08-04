// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to `winternl.h`.
class winternl {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  winternl(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  winternl.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int NtClose(
    HANDLE Handle,
  ) {
    return _NtClose(
      Handle,
    );
  }

  late final _NtClosePtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(HANDLE)>>('NtClose');
  late final _NtClose = _NtClosePtr.asFunction<int Function(HANDLE)>();

  int NtCreateFile(
    PHANDLE FileHandle,
    int DesiredAccess,
    POBJECT_ATTRIBUTES ObjectAttributes,
    PIO_STATUS_BLOCK IoStatusBlock,
    PLARGE_INTEGER AllocationSize,
    int FileAttributes,
    int ShareAccess,
    int CreateDisposition,
    int CreateOptions,
    PVOID EaBuffer,
    int EaLength,
  ) {
    return _NtCreateFile(
      FileHandle,
      DesiredAccess,
      ObjectAttributes,
      IoStatusBlock,
      AllocationSize,
      FileAttributes,
      ShareAccess,
      CreateDisposition,
      CreateOptions,
      EaBuffer,
      EaLength,
    );
  }

  late final _NtCreateFilePtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              PHANDLE,
              ACCESS_MASK,
              POBJECT_ATTRIBUTES,
              PIO_STATUS_BLOCK,
              PLARGE_INTEGER,
              ULONG,
              ULONG,
              ULONG,
              ULONG,
              PVOID,
              ULONG)>>('NtCreateFile');
  late final _NtCreateFile = _NtCreateFilePtr.asFunction<
      int Function(PHANDLE, int, POBJECT_ATTRIBUTES, PIO_STATUS_BLOCK,
          PLARGE_INTEGER, int, int, int, int, PVOID, int)>();

  int NtOpenFile(
    PHANDLE FileHandle,
    int DesiredAccess,
    POBJECT_ATTRIBUTES ObjectAttributes,
    PIO_STATUS_BLOCK IoStatusBlock,
    int ShareAccess,
    int OpenOptions,
  ) {
    return _NtOpenFile(
      FileHandle,
      DesiredAccess,
      ObjectAttributes,
      IoStatusBlock,
      ShareAccess,
      OpenOptions,
    );
  }

  late final _NtOpenFilePtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(PHANDLE, ACCESS_MASK, POBJECT_ATTRIBUTES,
              PIO_STATUS_BLOCK, ULONG, ULONG)>>('NtOpenFile');
  late final _NtOpenFile = _NtOpenFilePtr.asFunction<
      int Function(
          PHANDLE, int, POBJECT_ATTRIBUTES, PIO_STATUS_BLOCK, int, int)>();

  int NtRenameKey(
    HANDLE KeyHandle,
    PUNICODE_STRING NewName,
  ) {
    return _NtRenameKey(
      KeyHandle,
      NewName,
    );
  }

  late final _NtRenameKeyPtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(HANDLE, PUNICODE_STRING)>>(
          'NtRenameKey');
  late final _NtRenameKey =
      _NtRenameKeyPtr.asFunction<int Function(HANDLE, PUNICODE_STRING)>();

  int NtNotifyChangeMultipleKeys(
    HANDLE MasterKeyHandle,
    int Count,
    ffi.Pointer<OBJECT_ATTRIBUTES> SubordinateObjects,
    HANDLE Event,
    PIO_APC_ROUTINE ApcRoutine,
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock,
    int CompletionFilter,
    int WatchTree,
    PVOID Buffer,
    int BufferSize,
    int Asynchronous,
  ) {
    return _NtNotifyChangeMultipleKeys(
      MasterKeyHandle,
      Count,
      SubordinateObjects,
      Event,
      ApcRoutine,
      ApcContext,
      IoStatusBlock,
      CompletionFilter,
      WatchTree,
      Buffer,
      BufferSize,
      Asynchronous,
    );
  }

  late final _NtNotifyChangeMultipleKeysPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              HANDLE,
              ULONG,
              ffi.Pointer<OBJECT_ATTRIBUTES>,
              HANDLE,
              PIO_APC_ROUTINE,
              PVOID,
              PIO_STATUS_BLOCK,
              ULONG,
              BOOLEAN,
              PVOID,
              ULONG,
              BOOLEAN)>>('NtNotifyChangeMultipleKeys');
  late final _NtNotifyChangeMultipleKeys =
      _NtNotifyChangeMultipleKeysPtr.asFunction<
          int Function(
              HANDLE,
              int,
              ffi.Pointer<OBJECT_ATTRIBUTES>,
              HANDLE,
              PIO_APC_ROUTINE,
              PVOID,
              PIO_STATUS_BLOCK,
              int,
              int,
              PVOID,
              int,
              int)>();

  int NtQueryMultipleValueKey(
    HANDLE KeyHandle,
    PKEY_VALUE_ENTRY ValueEntries,
    int EntryCount,
    PVOID ValueBuffer,
    PULONG BufferLength,
    PULONG RequiredBufferLength,
  ) {
    return _NtQueryMultipleValueKey(
      KeyHandle,
      ValueEntries,
      EntryCount,
      ValueBuffer,
      BufferLength,
      RequiredBufferLength,
    );
  }

  late final _NtQueryMultipleValueKeyPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(HANDLE, PKEY_VALUE_ENTRY, ULONG, PVOID, PULONG,
              PULONG)>>('NtQueryMultipleValueKey');
  late final _NtQueryMultipleValueKey = _NtQueryMultipleValueKeyPtr.asFunction<
      int Function(HANDLE, PKEY_VALUE_ENTRY, int, PVOID, PULONG, PULONG)>();

  int NtSetInformationKey(
    HANDLE KeyHandle,
    int KeySetInformationClass,
    PVOID KeySetInformation,
    int KeySetInformationLength,
  ) {
    return _NtSetInformationKey(
      KeyHandle,
      KeySetInformationClass,
      KeySetInformation,
      KeySetInformationLength,
    );
  }

  late final _NtSetInformationKeyPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              HANDLE, ffi.Int32, PVOID, ULONG)>>('NtSetInformationKey');
  late final _NtSetInformationKey = _NtSetInformationKeyPtr.asFunction<
      int Function(HANDLE, int, PVOID, int)>();

  int NtDeviceIoControlFile(
    HANDLE FileHandle,
    HANDLE Event,
    PIO_APC_ROUTINE ApcRoutine,
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock,
    int IoControlCode,
    PVOID InputBuffer,
    int InputBufferLength,
    PVOID OutputBuffer,
    int OutputBufferLength,
  ) {
    return _NtDeviceIoControlFile(
      FileHandle,
      Event,
      ApcRoutine,
      ApcContext,
      IoStatusBlock,
      IoControlCode,
      InputBuffer,
      InputBufferLength,
      OutputBuffer,
      OutputBufferLength,
    );
  }

  late final _NtDeviceIoControlFilePtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              HANDLE,
              HANDLE,
              PIO_APC_ROUTINE,
              PVOID,
              PIO_STATUS_BLOCK,
              ULONG,
              PVOID,
              ULONG,
              PVOID,
              ULONG)>>('NtDeviceIoControlFile');
  late final _NtDeviceIoControlFile = _NtDeviceIoControlFilePtr.asFunction<
      int Function(HANDLE, HANDLE, PIO_APC_ROUTINE, PVOID, PIO_STATUS_BLOCK,
          int, PVOID, int, PVOID, int)>();

  int NtWaitForSingleObject(
    HANDLE Handle,
    int Alertable,
    PLARGE_INTEGER Timeout,
  ) {
    return _NtWaitForSingleObject(
      Handle,
      Alertable,
      Timeout,
    );
  }

  late final _NtWaitForSingleObjectPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              HANDLE, BOOLEAN, PLARGE_INTEGER)>>('NtWaitForSingleObject');
  late final _NtWaitForSingleObject = _NtWaitForSingleObjectPtr.asFunction<
      int Function(HANDLE, int, PLARGE_INTEGER)>();

  int RtlIsNameLegalDOS8Dot3(
    PUNICODE_STRING Name,
    POEM_STRING OemName,
    PBOOLEAN NameContainsSpaces,
  ) {
    return _RtlIsNameLegalDOS8Dot3(
      Name,
      OemName,
      NameContainsSpaces,
    );
  }

  late final _RtlIsNameLegalDOS8Dot3Ptr = _lookup<
      ffi.NativeFunction<
          BOOLEAN Function(PUNICODE_STRING, POEM_STRING,
              PBOOLEAN)>>('RtlIsNameLegalDOS8Dot3');
  late final _RtlIsNameLegalDOS8Dot3 = _RtlIsNameLegalDOS8Dot3Ptr.asFunction<
      int Function(PUNICODE_STRING, POEM_STRING, PBOOLEAN)>();

  int RtlNtStatusToDosError(
    int Status,
  ) {
    return _RtlNtStatusToDosError(
      Status,
    );
  }

  late final _RtlNtStatusToDosErrorPtr =
      _lookup<ffi.NativeFunction<ULONG Function(NTSTATUS)>>(
          'RtlNtStatusToDosError');
  late final _RtlNtStatusToDosError =
      _RtlNtStatusToDosErrorPtr.asFunction<int Function(int)>();

  int NtQueryInformationProcess(
    HANDLE ProcessHandle,
    int ProcessInformationClass,
    PVOID ProcessInformation,
    int ProcessInformationLength,
    PULONG ReturnLength,
  ) {
    return _NtQueryInformationProcess(
      ProcessHandle,
      ProcessInformationClass,
      ProcessInformation,
      ProcessInformationLength,
      ReturnLength,
    );
  }

  late final _NtQueryInformationProcessPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(HANDLE, ffi.Int32, PVOID, ULONG,
              PULONG)>>('NtQueryInformationProcess');
  late final _NtQueryInformationProcess = _NtQueryInformationProcessPtr
      .asFunction<int Function(HANDLE, int, PVOID, int, PULONG)>();

  int NtQueryInformationThread(
    HANDLE ThreadHandle,
    int ThreadInformationClass,
    PVOID ThreadInformation,
    int ThreadInformationLength,
    PULONG ReturnLength,
  ) {
    return _NtQueryInformationThread(
      ThreadHandle,
      ThreadInformationClass,
      ThreadInformation,
      ThreadInformationLength,
      ReturnLength,
    );
  }

  late final _NtQueryInformationThreadPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(HANDLE, ffi.Int32, PVOID, ULONG,
              PULONG)>>('NtQueryInformationThread');
  late final _NtQueryInformationThread = _NtQueryInformationThreadPtr
      .asFunction<int Function(HANDLE, int, PVOID, int, PULONG)>();

  int NtQueryObject(
    HANDLE Handle,
    int ObjectInformationClass,
    PVOID ObjectInformation,
    int ObjectInformationLength,
    PULONG ReturnLength,
  ) {
    return _NtQueryObject(
      Handle,
      ObjectInformationClass,
      ObjectInformation,
      ObjectInformationLength,
      ReturnLength,
    );
  }

  late final _NtQueryObjectPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              HANDLE, ffi.Int32, PVOID, ULONG, PULONG)>>('NtQueryObject');
  late final _NtQueryObject = _NtQueryObjectPtr.asFunction<
      int Function(HANDLE, int, PVOID, int, PULONG)>();

  int NtQuerySystemInformation(
    int SystemInformationClass,
    PVOID SystemInformation,
    int SystemInformationLength,
    PULONG ReturnLength,
  ) {
    return _NtQuerySystemInformation(
      SystemInformationClass,
      SystemInformation,
      SystemInformationLength,
      ReturnLength,
    );
  }

  late final _NtQuerySystemInformationPtr =
      _lookup<ffi.NativeFunction<NativeNtQuerySystemInformation>>(
          'NtQuerySystemInformation');
  late final _NtQuerySystemInformation =
      _NtQuerySystemInformationPtr.asFunction<DartNtQuerySystemInformation>();

  int NtQuerySystemTime(
    PLARGE_INTEGER SystemTime,
  ) {
    return _NtQuerySystemTime(
      SystemTime,
    );
  }

  late final _NtQuerySystemTimePtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(PLARGE_INTEGER)>>(
          'NtQuerySystemTime');
  late final _NtQuerySystemTime =
      _NtQuerySystemTimePtr.asFunction<int Function(PLARGE_INTEGER)>();

  int RtlLocalTimeToSystemTime(
    PLARGE_INTEGER LocalTime,
    PLARGE_INTEGER SystemTime,
  ) {
    return _RtlLocalTimeToSystemTime(
      LocalTime,
      SystemTime,
    );
  }

  late final _RtlLocalTimeToSystemTimePtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              PLARGE_INTEGER, PLARGE_INTEGER)>>('RtlLocalTimeToSystemTime');
  late final _RtlLocalTimeToSystemTime = _RtlLocalTimeToSystemTimePtr
      .asFunction<int Function(PLARGE_INTEGER, PLARGE_INTEGER)>();

  int RtlTimeToSecondsSince1970(
    PLARGE_INTEGER Time,
    PULONG ElapsedSeconds,
  ) {
    return _RtlTimeToSecondsSince1970(
      Time,
      ElapsedSeconds,
    );
  }

  late final _RtlTimeToSecondsSince1970Ptr =
      _lookup<ffi.NativeFunction<BOOLEAN Function(PLARGE_INTEGER, PULONG)>>(
          'RtlTimeToSecondsSince1970');
  late final _RtlTimeToSecondsSince1970 = _RtlTimeToSecondsSince1970Ptr
      .asFunction<int Function(PLARGE_INTEGER, PULONG)>();

  void RtlFreeAnsiString(
    PANSI_STRING AnsiString,
  ) {
    return _RtlFreeAnsiString(
      AnsiString,
    );
  }

  late final _RtlFreeAnsiStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PANSI_STRING)>>(
          'RtlFreeAnsiString');
  late final _RtlFreeAnsiString =
      _RtlFreeAnsiStringPtr.asFunction<void Function(PANSI_STRING)>();

  void RtlFreeUnicodeString(
    PUNICODE_STRING UnicodeString,
  ) {
    return _RtlFreeUnicodeString(
      UnicodeString,
    );
  }

  late final _RtlFreeUnicodeStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PUNICODE_STRING)>>(
          'RtlFreeUnicodeString');
  late final _RtlFreeUnicodeString =
      _RtlFreeUnicodeStringPtr.asFunction<void Function(PUNICODE_STRING)>();

  void RtlFreeOemString(
    POEM_STRING OemString,
  ) {
    return _RtlFreeOemString(
      OemString,
    );
  }

  late final _RtlFreeOemStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(POEM_STRING)>>(
          'RtlFreeOemString');
  late final _RtlFreeOemString =
      _RtlFreeOemStringPtr.asFunction<void Function(POEM_STRING)>();

  void RtlInitString(
    PSTRING DestinationString,
    PCSZ SourceString,
  ) {
    return _RtlInitString(
      DestinationString,
      SourceString,
    );
  }

  late final _RtlInitStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PSTRING, PCSZ)>>(
          'RtlInitString');
  late final _RtlInitString =
      _RtlInitStringPtr.asFunction<void Function(PSTRING, PCSZ)>();

  int RtlInitStringEx(
    PSTRING DestinationString,
    PCSZ SourceString,
  ) {
    return _RtlInitStringEx(
      DestinationString,
      SourceString,
    );
  }

  late final _RtlInitStringExPtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(PSTRING, PCSZ)>>(
          'RtlInitStringEx');
  late final _RtlInitStringEx =
      _RtlInitStringExPtr.asFunction<int Function(PSTRING, PCSZ)>();

  void RtlInitAnsiString(
    PANSI_STRING DestinationString,
    PCSZ SourceString,
  ) {
    return _RtlInitAnsiString(
      DestinationString,
      SourceString,
    );
  }

  late final _RtlInitAnsiStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PANSI_STRING, PCSZ)>>(
          'RtlInitAnsiString');
  late final _RtlInitAnsiString =
      _RtlInitAnsiStringPtr.asFunction<void Function(PANSI_STRING, PCSZ)>();

  int RtlInitAnsiStringEx(
    PANSI_STRING DestinationString,
    PCSZ SourceString,
  ) {
    return _RtlInitAnsiStringEx(
      DestinationString,
      SourceString,
    );
  }

  late final _RtlInitAnsiStringExPtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(PANSI_STRING, PCSZ)>>(
          'RtlInitAnsiStringEx');
  late final _RtlInitAnsiStringEx =
      _RtlInitAnsiStringExPtr.asFunction<int Function(PANSI_STRING, PCSZ)>();

  void RtlInitUnicodeString(
    PUNICODE_STRING DestinationString,
    PCWSTR SourceString,
  ) {
    return _RtlInitUnicodeString(
      DestinationString,
      SourceString,
    );
  }

  late final _RtlInitUnicodeStringPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(PUNICODE_STRING, PCWSTR)>>(
          'RtlInitUnicodeString');
  late final _RtlInitUnicodeString = _RtlInitUnicodeStringPtr.asFunction<
      void Function(PUNICODE_STRING, PCWSTR)>();

  int RtlAnsiStringToUnicodeString(
    PUNICODE_STRING DestinationString,
    PCANSI_STRING SourceString,
    int AllocateDestinationString,
  ) {
    return _RtlAnsiStringToUnicodeString(
      DestinationString,
      SourceString,
      AllocateDestinationString,
    );
  }

  late final _RtlAnsiStringToUnicodeStringPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(PUNICODE_STRING, PCANSI_STRING,
              BOOLEAN)>>('RtlAnsiStringToUnicodeString');
  late final _RtlAnsiStringToUnicodeString = _RtlAnsiStringToUnicodeStringPtr
      .asFunction<int Function(PUNICODE_STRING, PCANSI_STRING, int)>();

  int RtlUnicodeStringToAnsiString(
    PANSI_STRING DestinationString,
    PCUNICODE_STRING SourceString,
    int AllocateDestinationString,
  ) {
    return _RtlUnicodeStringToAnsiString(
      DestinationString,
      SourceString,
      AllocateDestinationString,
    );
  }

  late final _RtlUnicodeStringToAnsiStringPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(PANSI_STRING, PCUNICODE_STRING,
              BOOLEAN)>>('RtlUnicodeStringToAnsiString');
  late final _RtlUnicodeStringToAnsiString = _RtlUnicodeStringToAnsiStringPtr
      .asFunction<int Function(PANSI_STRING, PCUNICODE_STRING, int)>();

  int RtlUnicodeStringToOemString(
    POEM_STRING DestinationString,
    PCUNICODE_STRING SourceString,
    int AllocateDestinationString,
  ) {
    return _RtlUnicodeStringToOemString(
      DestinationString,
      SourceString,
      AllocateDestinationString,
    );
  }

  late final _RtlUnicodeStringToOemStringPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(POEM_STRING, PCUNICODE_STRING,
              BOOLEAN)>>('RtlUnicodeStringToOemString');
  late final _RtlUnicodeStringToOemString = _RtlUnicodeStringToOemStringPtr
      .asFunction<int Function(POEM_STRING, PCUNICODE_STRING, int)>();

  int RtlUnicodeToMultiByteSize(
    PULONG BytesInMultiByteString,
    PWCH UnicodeString,
    int BytesInUnicodeString,
  ) {
    return _RtlUnicodeToMultiByteSize(
      BytesInMultiByteString,
      UnicodeString,
      BytesInUnicodeString,
    );
  }

  late final _RtlUnicodeToMultiByteSizePtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(PULONG, PWCH, ULONG)>>(
          'RtlUnicodeToMultiByteSize');
  late final _RtlUnicodeToMultiByteSize = _RtlUnicodeToMultiByteSizePtr
      .asFunction<int Function(PULONG, PWCH, int)>();

  int RtlCharToInteger(
    PCSZ String,
    int Base,
    PULONG Value,
  ) {
    return _RtlCharToInteger(
      String,
      Base,
      Value,
    );
  }

  late final _RtlCharToIntegerPtr =
      _lookup<ffi.NativeFunction<NTSTATUS Function(PCSZ, ULONG, PULONG)>>(
          'RtlCharToInteger');
  late final _RtlCharToInteger =
      _RtlCharToIntegerPtr.asFunction<int Function(PCSZ, int, PULONG)>();

  int RtlConvertSidToUnicodeString(
    PUNICODE_STRING UnicodeString,
    PSID Sid,
    int AllocateDestinationString,
  ) {
    return _RtlConvertSidToUnicodeString(
      UnicodeString,
      Sid,
      AllocateDestinationString,
    );
  }

  late final _RtlConvertSidToUnicodeStringPtr = _lookup<
      ffi.NativeFunction<
          NTSTATUS Function(
              PUNICODE_STRING, PSID, BOOLEAN)>>('RtlConvertSidToUnicodeString');
  late final _RtlConvertSidToUnicodeString = _RtlConvertSidToUnicodeStringPtr
      .asFunction<int Function(PUNICODE_STRING, PSID, int)>();

  int RtlUniform(
    PULONG Seed,
  ) {
    return _RtlUniform(
      Seed,
    );
  }

  late final _RtlUniformPtr =
      _lookup<ffi.NativeFunction<ULONG Function(PULONG)>>('RtlUniform');
  late final _RtlUniform = _RtlUniformPtr.asFunction<int Function(PULONG)>();
}

class _STRING extends ffi.Struct {
  @USHORT()
  external int Length;

  @USHORT()
  external int MaximumLength;

  external PCHAR Buffer;
}

typedef USHORT = ffi.Uint16;
typedef PCHAR = ffi.Pointer<CHAR>;
typedef CHAR = ffi.Int8;

class _UNICODE_STRING extends ffi.Struct {
  @USHORT()
  external int Length;

  @USHORT()
  external int MaximumLength;

  external PWSTR Buffer;
}

typedef PWSTR = ffi.Pointer<WCHAR>;
typedef WCHAR = wchar_t;
typedef wchar_t = ffi.Uint16;

class _CLIENT_ID extends ffi.Struct {
  external HANDLE UniqueProcess;

  external HANDLE UniqueThread;
}

typedef HANDLE = ffi.Pointer<ffi.Void>;

class _PEB_LDR_DATA extends ffi.Struct {
  @ffi.Array.multi([8])
  external ffi.Array<BYTE> Reserved1;

  @ffi.Array.multi([3])
  external ffi.Array<PVOID> Reserved2;

  external LIST_ENTRY InMemoryOrderModuleList;
}

typedef BYTE = ffi.Uint8;
typedef PVOID = ffi.Pointer<ffi.Void>;
typedef LIST_ENTRY = _LIST_ENTRY;

class _LIST_ENTRY extends ffi.Struct {
  external ffi.Pointer<_LIST_ENTRY> Flink;

  external ffi.Pointer<_LIST_ENTRY> Blink;
}

class _LDR_DATA_TABLE_ENTRY extends ffi.Struct {
  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved1;

  external LIST_ENTRY InMemoryOrderLinks;

  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved2;

  external PVOID DllBase;

  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved3;

  external UNICODE_STRING FullDllName;

  @ffi.Array.multi([8])
  external ffi.Array<BYTE> Reserved4;

  @ffi.Array.multi([3])
  external ffi.Array<PVOID> Reserved5;

  @ULONG()
  external int TimeDateStamp;
}

typedef UNICODE_STRING = _UNICODE_STRING;
typedef ULONG = DWORD;
typedef DWORD = ffi.Uint32;

class _RTL_USER_PROCESS_PARAMETERS extends ffi.Struct {
  @ffi.Array.multi([16])
  external ffi.Array<BYTE> Reserved1;

  @ffi.Array.multi([10])
  external ffi.Array<PVOID> Reserved2;

  external UNICODE_STRING ImagePathName;

  external UNICODE_STRING CommandLine;
}

class _PEB extends ffi.Struct {
  @ffi.Array.multi([2])
  external ffi.Array<BYTE> Reserved1;

  @BYTE()
  external int BeingDebugged;

  @ffi.Array.multi([1])
  external ffi.Array<BYTE> Reserved2;

  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved3;

  external PPEB_LDR_DATA Ldr;

  external PRTL_USER_PROCESS_PARAMETERS ProcessParameters;

  @ffi.Array.multi([3])
  external ffi.Array<PVOID> Reserved4;

  external PVOID AtlThunkSListPtr;

  external PVOID Reserved5;

  @ULONG()
  external int Reserved6;

  external PVOID Reserved7;

  @ULONG()
  external int Reserved8;

  @ULONG()
  external int AtlThunkSListPtr32;

  @ffi.Array.multi([45])
  external ffi.Array<PVOID> Reserved9;

  @ffi.Array.multi([96])
  external ffi.Array<BYTE> Reserved10;

  external PPS_POST_PROCESS_INIT_ROUTINE PostProcessInitRoutine;

  @ffi.Array.multi([128])
  external ffi.Array<BYTE> Reserved11;

  @ffi.Array.multi([1])
  external ffi.Array<PVOID> Reserved12;

  @ULONG()
  external int SessionId;
}

typedef PPEB_LDR_DATA = ffi.Pointer<_PEB_LDR_DATA>;
typedef PRTL_USER_PROCESS_PARAMETERS
    = ffi.Pointer<_RTL_USER_PROCESS_PARAMETERS>;
typedef PPS_POST_PROCESS_INIT_ROUTINE
    = ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>;

class _TEB extends ffi.Struct {
  @ffi.Array.multi([12])
  external ffi.Array<PVOID> Reserved1;

  external PPEB ProcessEnvironmentBlock;

  @ffi.Array.multi([399])
  external ffi.Array<PVOID> Reserved2;

  @ffi.Array.multi([1952])
  external ffi.Array<BYTE> Reserved3;

  @ffi.Array.multi([64])
  external ffi.Array<PVOID> TlsSlots;

  @ffi.Array.multi([8])
  external ffi.Array<BYTE> Reserved4;

  @ffi.Array.multi([26])
  external ffi.Array<PVOID> Reserved5;

  external PVOID ReservedForOle;

  @ffi.Array.multi([4])
  external ffi.Array<PVOID> Reserved6;

  external PVOID TlsExpansionSlots;
}

typedef PPEB = ffi.Pointer<_PEB>;

class _OBJECT_ATTRIBUTES extends ffi.Struct {
  @ULONG()
  external int Length;

  external HANDLE RootDirectory;

  external PUNICODE_STRING ObjectName;

  @ULONG()
  external int Attributes;

  external PVOID SecurityDescriptor;

  external PVOID SecurityQualityOfService;
}

typedef PUNICODE_STRING = ffi.Pointer<UNICODE_STRING>;

class _IO_STATUS_BLOCK extends ffi.Struct {
  @ULONG_PTR()
  external int Information;
}

typedef ULONG_PTR = ffi.Uint64;

class _PROCESS_BASIC_INFORMATION extends ffi.Struct {
  external PVOID Reserved1;

  external PPEB PebBaseAddress;

  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved2;

  @ULONG_PTR()
  external int UniqueProcessId;

  external PVOID Reserved3;
}

class SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION extends ffi.Struct {
  external LARGE_INTEGER IdleTime;

  external LARGE_INTEGER KernelTime;

  external LARGE_INTEGER UserTime;

  @ffi.Array.multi([2])
  external ffi.Array<LARGE_INTEGER> Reserved1;

  @ULONG()
  external int Reserved2;
}

typedef LARGE_INTEGER = _LARGE_INTEGER;

class _LARGE_INTEGER extends ffi.Union {
  external UnnamedStruct1 u;

  @LONGLONG()
  external int QuadPart;
}

class UnnamedStruct1 extends ffi.Struct {
  @DWORD()
  external int LowPart;

  @LONG()
  external int HighPart;
}

typedef LONG = ffi.Int32;
typedef LONGLONG = ffi.Int64;

class SYSTEM_PROCESS_INFORMATION extends ffi.Struct {
  @ULONG()
  external int NextEntryOffset;

  @ULONG()
  external int NumberOfThreads;

  @ffi.Array.multi([48])
  external ffi.Array<BYTE> Reserved1;

  external UNICODE_STRING ImageName;

  @KPRIORITY()
  external int BasePriority;

  external HANDLE UniqueProcessId;

  external PVOID Reserved2;

  @ULONG()
  external int HandleCount;

  @ULONG()
  external int SessionId;

  external PVOID Reserved3;

  @SIZE_T()
  external int PeakVirtualSize;

  @SIZE_T()
  external int VirtualSize;

  @ULONG()
  external int Reserved4;

  @SIZE_T()
  external int PeakWorkingSetSize;

  @SIZE_T()
  external int WorkingSetSize;

  external PVOID Reserved5;

  @SIZE_T()
  external int QuotaPagedPoolUsage;

  external PVOID Reserved6;

  @SIZE_T()
  external int QuotaNonPagedPoolUsage;

  @SIZE_T()
  external int PagefileUsage;

  @SIZE_T()
  external int PeakPagefileUsage;

  @SIZE_T()
  external int PrivatePageCount;

  @ffi.Array.multi([6])
  external ffi.Array<LARGE_INTEGER> Reserved7;
}

typedef KPRIORITY = LONG;
typedef SIZE_T = ULONG_PTR;

class SYSTEM_THREAD_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([3])
  external ffi.Array<LARGE_INTEGER> Reserved1;

  @ULONG()
  external int Reserved2;

  external PVOID StartAddress;

  external CLIENT_ID ClientId;

  @KPRIORITY()
  external int Priority;

  @LONG()
  external int BasePriority;

  @ULONG()
  external int Reserved3;

  @ULONG()
  external int ThreadState;

  @ULONG()
  external int WaitReason;
}

typedef CLIENT_ID = _CLIENT_ID;

class SYSTEM_REGISTRY_QUOTA_INFORMATION extends ffi.Struct {
  @ULONG()
  external int RegistryQuotaAllowed;

  @ULONG()
  external int RegistryQuotaUsed;

  external PVOID Reserved1;
}

class SYSTEM_BASIC_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([24])
  external ffi.Array<BYTE> Reserved1;

  @ffi.Array.multi([4])
  external ffi.Array<PVOID> Reserved2;

  @CCHAR()
  external int NumberOfProcessors;
}

typedef CCHAR = ffi.Int8;

class SYSTEM_TIMEOFDAY_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([48])
  external ffi.Array<BYTE> Reserved1;
}

class SYSTEM_PERFORMANCE_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([312])
  external ffi.Array<BYTE> Reserved1;
}

class SYSTEM_EXCEPTION_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([16])
  external ffi.Array<BYTE> Reserved1;
}

class SYSTEM_LOOKASIDE_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([32])
  external ffi.Array<BYTE> Reserved1;
}

class SYSTEM_INTERRUPT_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([24])
  external ffi.Array<BYTE> Reserved1;
}

class SYSTEM_POLICY_INFORMATION extends ffi.Struct {
  @ffi.Array.multi([2])
  external ffi.Array<PVOID> Reserved1;

  @ffi.Array.multi([3])
  external ffi.Array<ULONG> Reserved2;
}

abstract class _FILE_INFORMATION_CLASS {
  static const int FileDirectoryInformation = 1;
}

abstract class _PROCESSINFOCLASS {
  static const int ProcessBasicInformation = 0;
  static const int ProcessDebugPort = 7;
  static const int ProcessWow64Information = 26;
  static const int ProcessImageFileName = 27;
  static const int ProcessBreakOnTermination = 29;
}

abstract class _THREADINFOCLASS {
  static const int ThreadIsIoPending = 16;
}

class SYSTEM_CODEINTEGRITY_INFORMATION extends ffi.Struct {
  @ULONG()
  external int Length;

  @ULONG()
  external int CodeIntegrityOptions;
}

abstract class SYSTEM_INFORMATION_CLASS {
  static const int SystemBasicInformation = 0;
  static const int SystemPerformanceInformation = 2;
  static const int SystemTimeOfDayInformation = 3;
  static const int SystemProcessInformation = 5;
  static const int SystemProcessorPerformanceInformation = 8;
  static const int SystemInterruptInformation = 23;
  static const int SystemExceptionInformation = 33;
  static const int SystemRegistryQuotaInformation = 37;
  static const int SystemLookasideInformation = 45;
  static const int SystemCodeIntegrityInformation = 103;
  static const int SystemPolicyInformation = 134;
}

abstract class _OBJECT_INFORMATION_CLASS {
  static const int ObjectBasicInformation = 0;
  static const int ObjectTypeInformation = 2;
}

class _PUBLIC_OBJECT_BASIC_INFORMATION extends ffi.Struct {
  @ULONG()
  external int Attributes;

  @ACCESS_MASK()
  external int GrantedAccess;

  @ULONG()
  external int HandleCount;

  @ULONG()
  external int PointerCount;

  @ffi.Array.multi([10])
  external ffi.Array<ULONG> Reserved;
}

typedef ACCESS_MASK = DWORD;

class __PUBLIC_OBJECT_TYPE_INFORMATION extends ffi.Struct {
  external UNICODE_STRING TypeName;

  @ffi.Array.multi([22])
  external ffi.Array<ULONG> Reserved;
}

typedef NTSTATUS = LONG;
typedef PHANDLE = ffi.Pointer<HANDLE>;
typedef POBJECT_ATTRIBUTES = ffi.Pointer<OBJECT_ATTRIBUTES>;
typedef OBJECT_ATTRIBUTES = _OBJECT_ATTRIBUTES;
typedef PIO_STATUS_BLOCK = ffi.Pointer<_IO_STATUS_BLOCK>;
typedef PLARGE_INTEGER = ffi.Pointer<LARGE_INTEGER>;
typedef PIO_APC_ROUTINE = ffi.Pointer<
    ffi.NativeFunction<ffi.Void Function(PVOID, PIO_STATUS_BLOCK, ULONG)>>;
typedef BOOLEAN = boolean;
typedef boolean = ffi.Uint8;

class _KEY_VALUE_ENTRY extends ffi.Struct {
  external PUNICODE_STRING ValueName;

  @ULONG()
  external int DataLength;

  @ULONG()
  external int DataOffset;

  @ULONG()
  external int Type;
}

typedef PKEY_VALUE_ENTRY = ffi.Pointer<_KEY_VALUE_ENTRY>;
typedef PULONG = ffi.Pointer<ULONG>;

abstract class _KEY_SET_INFORMATION_CLASS {
  static const int KeyWriteTimeInformation = 0;
  static const int KeyWow64FlagsInformation = 1;
  static const int KeyControlFlagsInformation = 2;
  static const int KeySetVirtualizationInformation = 3;
  static const int KeySetDebugInformation = 4;
  static const int KeySetHandleTagsInformation = 5;
  static const int MaxKeySetInfoClass = 6;
}

typedef POEM_STRING = PSTRING;
typedef PSTRING = ffi.Pointer<STRING>;
typedef STRING = _STRING;
typedef PBOOLEAN = ffi.Pointer<BOOLEAN>;
typedef NativeNtQuerySystemInformation = NTSTATUS Function(
    ffi.Int32 SystemInformationClass,
    PVOID SystemInformation,
    ULONG SystemInformationLength,
    PULONG ReturnLength);
typedef DartNtQuerySystemInformation = int Function(int SystemInformationClass,
    PVOID SystemInformation, int SystemInformationLength, PULONG ReturnLength);
typedef PANSI_STRING = PSTRING;
typedef PCSZ = ffi.Pointer<ffi.Int8>;
typedef PCWSTR = ffi.Pointer<WCHAR>;
typedef PCANSI_STRING = PSTRING;
typedef PCUNICODE_STRING = ffi.Pointer<UNICODE_STRING>;
typedef PWCH = ffi.Pointer<WCHAR>;
typedef PSID = PVOID;

abstract class _WINSTATIONINFOCLASS {
  static const int WinStationInformation = 8;
}

class _WINSTATIONINFORMATIONW extends ffi.Struct {
  @ffi.Array.multi([70])
  external ffi.Array<BYTE> Reserved2;

  @ULONG()
  external int LogonId;

  @ffi.Array.multi([1140])
  external ffi.Array<BYTE> Reserved3;
}

const int CODEINTEGRITY_OPTION_ENABLED = 1;

const int CODEINTEGRITY_OPTION_TESTSIGN = 2;

const int CODEINTEGRITY_OPTION_UMCI_ENABLED = 4;

const int CODEINTEGRITY_OPTION_UMCI_AUDITMODE_ENABLED = 8;

const int CODEINTEGRITY_OPTION_UMCI_EXCLUSIONPATHS_ENABLED = 16;

const int CODEINTEGRITY_OPTION_TEST_BUILD = 32;

const int CODEINTEGRITY_OPTION_PREPRODUCTION_BUILD = 64;

const int CODEINTEGRITY_OPTION_DEBUGMODE_ENABLED = 128;

const int CODEINTEGRITY_OPTION_FLIGHT_BUILD = 256;

const int CODEINTEGRITY_OPTION_FLIGHTING_ENABLED = 512;

const int CODEINTEGRITY_OPTION_HVCI_KMCI_ENABLED = 1024;

const int CODEINTEGRITY_OPTION_HVCI_KMCI_AUDITMODE_ENABLED = 2048;

const int CODEINTEGRITY_OPTION_HVCI_KMCI_STRICTMODE_ENABLED = 4096;

const int CODEINTEGRITY_OPTION_HVCI_IUM_ENABLED = 8192;

const int LOGONID_CURRENT = 4294967295;

const int OBJ_INHERIT = 2;

const int OBJ_PERMANENT = 16;

const int OBJ_EXCLUSIVE = 32;

const int OBJ_CASE_INSENSITIVE = 64;

const int OBJ_OPENIF = 128;

const int OBJ_OPENLINK = 256;

const int OBJ_KERNEL_HANDLE = 512;

const int OBJ_FORCE_ACCESS_CHECK = 1024;

const int OBJ_IGNORE_IMPERSONATED_DEVICEMAP = 2048;

const int OBJ_DONT_REPARSE = 4096;

const int OBJ_VALID_ATTRIBUTES = 8178;

const int FILE_SUPERSEDE = 0;

const int FILE_OPEN = 1;

const int FILE_CREATE = 2;

const int FILE_OPEN_IF = 3;

const int FILE_OVERWRITE = 4;

const int FILE_OVERWRITE_IF = 5;

const int FILE_MAXIMUM_DISPOSITION = 5;

const int FILE_DIRECTORY_FILE = 1;

const int FILE_WRITE_THROUGH = 2;

const int FILE_SEQUENTIAL_ONLY = 4;

const int FILE_NO_INTERMEDIATE_BUFFERING = 8;

const int FILE_SYNCHRONOUS_IO_ALERT = 16;

const int FILE_SYNCHRONOUS_IO_NONALERT = 32;

const int FILE_NON_DIRECTORY_FILE = 64;

const int FILE_CREATE_TREE_CONNECTION = 128;

const int FILE_COMPLETE_IF_OPLOCKED = 256;

const int FILE_NO_EA_KNOWLEDGE = 512;

const int FILE_OPEN_REMOTE_INSTANCE = 1024;

const int FILE_RANDOM_ACCESS = 2048;

const int FILE_DELETE_ON_CLOSE = 4096;

const int FILE_OPEN_BY_FILE_ID = 8192;

const int FILE_OPEN_FOR_BACKUP_INTENT = 16384;

const int FILE_NO_COMPRESSION = 32768;

const int FILE_OPEN_REQUIRING_OPLOCK = 65536;

const int FILE_RESERVE_OPFILTER = 1048576;

const int FILE_OPEN_REPARSE_POINT = 2097152;

const int FILE_OPEN_NO_RECALL = 4194304;

const int FILE_OPEN_FOR_FREE_SPACE_QUERY = 8388608;

const int FILE_VALID_OPTION_FLAGS = 16777215;

const int FILE_VALID_PIPE_OPTION_FLAGS = 50;

const int FILE_VALID_MAILSLOT_OPTION_FLAGS = 50;

const int FILE_VALID_SET_FLAGS = 54;

const int FILE_SUPERSEDED = 0;

const int FILE_OPENED = 1;

const int FILE_CREATED = 2;

const int FILE_OVERWRITTEN = 3;

const int FILE_EXISTS = 4;

const int FILE_DOES_NOT_EXIST = 5;
