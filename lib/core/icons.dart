import 'constants.dart';

/// The paths to the app's icons.
abstract class AppIcons {
  /// Asset directory containing the app's icons.
  static const String path = 'assets/icons';

  /// Normal icon as an SVG.
  static const String linux = '$path/$kPackageId.svg';

  /// Normal icon as an ICO.
  static const String windows = '$path/$kPackageId.ico';
}
