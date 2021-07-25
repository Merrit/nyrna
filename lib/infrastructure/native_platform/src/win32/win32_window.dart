import 'package:win32/win32.dart';

import '../window.dart';

/// Win32 specific window controls using the win32 API.
class Win32WindowControls implements WindowControls {
  @override
  Future<void> minimize(int? id) async => ShowWindow(id!, SW_FORCEMINIMIZE);

  @override
  Future<void> restore(int? id) async => ShowWindow(id!, SW_RESTORE);
}
