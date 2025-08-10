// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get filterWindows => 'Filter windows';

  @override
  String get favoriteButtonTooltipAdd => 'Add to favorites';

  @override
  String get favoriteButtonTooltipRemove => 'Remove from favorites';

  @override
  String get detailsDialogTitle => 'Details';

  @override
  String get detailsDialogWindowTitle => 'Window Title';

  @override
  String get detailsDialogExecutableName => 'Executable Name';

  @override
  String get detailsDialogPID => 'PID';

  @override
  String get detailsDialogCurrentStatus => 'Current Status';

  @override
  String get copyLogs => 'Copy logs';

  @override
  String get logsCopiedNotification => 'Logs copied to clipboard';

  @override
  String get donate => 'Donate';

  @override
  String get donateMessage =>
      'If you like this application, please consider donating to support its development.';

  @override
  String get madeBy => 'Made with 💙 by ';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get behaviourTitle => 'Behaviour';

  @override
  String get autoRefresh => 'Auto Refresh';

  @override
  String get autoRefreshDescription =>
      'Update window & process info automatically';

  @override
  String get autoRefreshInterval => 'Auto Refresh Interval';

  @override
  String autoRefreshIntervalAmount(int interval) {
    return '$interval seconds';
  }

  @override
  String get closeToTray => 'Close to tray';

  @override
  String get minimizeAndRestoreWindows => 'Minimize / restore windows';

  @override
  String get pinSuspendedWindows => 'Pin suspended windows';

  @override
  String get pinSuspendedWindowsTooltip =>
      'If enabled, suspended windows will always be shown at the top of the window list.';

  @override
  String get showHiddenWindows => 'Show hidden windows';

  @override
  String get showHiddenWindowsTooltip =>
      'Includes windows from other virtual desktops and special windows that are not normally detected.';

  @override
  String get themeTitle => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get pitchBlack => 'Pitch Black';

  @override
  String get systemIntegrationTitle => 'System Integration';

  @override
  String get startAutomatically => 'Start automatically at system boot';

  @override
  String get startInTray => 'Start hidden in system tray';

  @override
  String get troubleshootingTitle => 'Troubleshooting';

  @override
  String get logs => 'Logs';

  @override
  String get aboutTitle => 'About';

  @override
  String get version => 'Nyrna version';

  @override
  String get homepage => 'Nyrna homepage';

  @override
  String get repository => 'GitHub repository';
}
