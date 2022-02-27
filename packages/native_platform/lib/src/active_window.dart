import '../native_platform.dart';

class ActiveWindow {
  final NativePlatform _nativePlatform;
  final Process _process;

  final int id;
  final int pid;

  const ActiveWindow(
    this._nativePlatform,
    this._process, {
    required this.id,
    required this.pid,
  });

  String get executable => _process.executable;

  Future<bool> minimize() async => await _nativePlatform.minimizeWindow(id);

  Future<bool> restore() async => await _nativePlatform.restoreWindow(id);

  Future<ProcessStatus> status() async => await _process.refreshStatus();

  Future<bool> suspend() async => await _process.suspend();

  Future<bool> resume() async => await _process.resume();
}
