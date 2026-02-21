import '../../../native_platform.dart';
import '../../typedefs.dart';
import '../linux.dart';

/// Information on the active window in X11.
///
/// Fetches the information when created.
class ActiveWindowX11 {
  final Linux _linux;
  final RunFunction _run;

  ActiveWindowX11._(this._linux, this._run);

  /// Returns a [Window] object representing the active window.
  static Future<void> fetch(Linux linux, RunFunction run) async {
    final activeWindow = ActiveWindowX11._(linux, run);
    await activeWindow._fetchActiveWindowInfo();
  }

  Future<void> _fetchActiveWindowInfo() async {
    final windowId = await _activeWindowId();
    if (windowId == '0') throw (Exception('No window id'));

    final pid = await _activeWindowPid(windowId);
    if (pid == 0) throw (Exception('No pid'));

    final executable = await _linux.getExecutableName(pid);
    final title = await _activeWindowTitle();

    final process = Process(
      pid: pid,
      executable: executable,
      status: ProcessStatus.unknown,
    );

    // return Window(
    //   id: windowId,
    //   process: process,
    //   title: title,
    // );

    final window = Window(
      id: windowId,
      process: process,
      title: title,
    );

    _linux.activeWindow = window;
    // _linux.updateActiveWindow(window);
  }

  // Returns the unique hex ID of the active window as reported by xdotool.
  Future<String> _activeWindowId() async {
    final result = await _run('xdotool', ['getactivewindow']);
    final windowId = result.stdout.toString().trim();
    return windowId;
  }

  Future<int> _activeWindowPid(String windowId) async {
    final result = await _run(
      'xdotool',
      ['getwindowpid', windowId],
    );
    final pid = int.tryParse(result.stdout.toString().trim());
    return pid ?? 0;
  }

  Future<String> _activeWindowTitle() async {
    final result = await _run(
      'xdotool',
      ['getactivewindow getwindowname'],
    );
    return result.stdout.toString().trim();
  }
}
