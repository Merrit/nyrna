import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

int getFuncAddress(String module, String func) {
  return using((Arena arena) {
    final hModule = GetModuleHandle(module.toNativeUtf16(allocator: arena));
    if (hModule == NULL) throw Exception('Could not load $module');

    final pFuncAddress = GetProcAddress(hModule, func.toANSI(allocator: arena));
    if (pFuncAddress == NULL) throw Exception('Could not find $func()');

    return pFuncAddress;
  });
}
