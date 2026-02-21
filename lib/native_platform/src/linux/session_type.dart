import 'dart:io' as io;

import '../../../logs/logging_manager.dart';

/// Enum representing the display protocol used by the Linux session.
enum DisplayProtocol {
  wayland,
  x11,
  unknown;

  /// Create DisplayProtocol from string.
  static DisplayProtocol fromString(String protocol) {
    return DisplayProtocol.values.firstWhere(
      (e) => e.name.toLowerCase() == protocol.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid display protocol: $protocol'),
    );
  }
}

/// Enum representing the Desktop Environment.
enum DesktopEnvironment {
  /// KDE Plasma desktop environment.
  kde,

  /// GNOME desktop environment.
  gnome,

  /// XFCE desktop environment.
  xfce,

  /// Unknown desktop environment.
  unknown;

  /// Create DesktopEnvironment from string.
  static DesktopEnvironment fromString(String environment) {
    return DesktopEnvironment.values.firstWhere(
      (e) => e.name.toLowerCase() == environment.toLowerCase(),
      orElse: () => DesktopEnvironment.unknown,
    );
  }
}

/// Information about the current Linux desktop session.
class SessionType {
  const SessionType({
    required this.displayProtocol,
    required this.environment,
  });

  final DisplayProtocol displayProtocol;
  final DesktopEnvironment environment;

  /// Create a SessionType from environment variables.
  static Future<SessionType> fromEnvironment() async {
    final displayProtocolEnv = io.Platform.environment['XDG_SESSION_TYPE'];
    if (displayProtocolEnv == null || displayProtocolEnv.isEmpty) {
      log.e('XDG_SESSION_TYPE is not set');
      return Future.error('XDG_SESSION_TYPE is not set');
    }

    final displayProtocol = DisplayProtocol.fromString(displayProtocolEnv);

    final environmentEnv = io.Platform.environment['XDG_CURRENT_DESKTOP'];
    if (environmentEnv == null || environmentEnv.isEmpty) {
      log.e('XDG_CURRENT_DESKTOP is not set');
      return Future.error('XDG_CURRENT_DESKTOP is not set');
    }

    final environment = DesktopEnvironment.fromString(environmentEnv);
    return SessionType(
      displayProtocol: displayProtocol,
      environment: environment,
    );
  }

  @override
  String toString() {
    return 'SessionType(displayProtocol: $displayProtocol, environment: $environment)';
  }
}
