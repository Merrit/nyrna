import '../native_platform.dart';

class NativeActiveWindow {
  final NativePlatform _nativePlatform;
  final NativeProcess _nativeProcess;

  final int id;
  final int pid;

  const NativeActiveWindow(
    this._nativePlatform,
    this._nativeProcess, {
    required this.id,
    required this.pid,
  });

  Future<String> executable() async => await _nativeProcess.executable;

  Future<bool> minimize() async => await _nativePlatform.minimizeWindow(id);

  Future<bool> restore() async => await _nativePlatform.restoreWindow(id);

  Future<ProcessStatus> status() async => await _nativeProcess.status;

  Future<bool> suspend() async => await _nativeProcess.suspend();

  Future<bool> resume() async => await _nativeProcess.resume();
}
