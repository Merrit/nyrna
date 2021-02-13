/// Abstract type bridges classes for specific operating systems.
/// Used by [LinuxProcess] and [WindowsProcess].
abstract class NativeProcess {
  /// Status will be one of [normal], [suspended] or [unknown].
  String get status;

  /// Returns true for success or false for failure.
  bool toggle();
}
