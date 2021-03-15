// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

final _dwmapi = DynamicLibrary.open('Dwmapi.dll');

const DWMWA_CLOAKED = 14;

/// Retrieves the current value of a specified
/// Desktop Window Manager (DWM) attribute applied to a window.
///
/// ```cpp
//  DWMAPI DwmGetWindowAttribute(
//    HWND  hwnd,
//    DWORD dwAttribute,
//    PVOID pvAttribute,
//    DWORD cbAttribute
//  );
/// ```
int DwmGetWindowAttribute(
    int hwnd, int dwAttribute, Pointer pvAttribute, int cbAttribute) {
  final _DwmGetWindowAttribute = _dwmapi.lookupFunction<
      Int32 Function(Int32 hwnd, Uint32 dwAttribute, Pointer pvAttribute,
          Uint32 cbAttribute),
      int Function(int hwnd, int dwAttribute, Pointer pvAttribute,
          int cbAttribute)>('DwmGetWindowAttribute');
  return _DwmGetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute);
}
