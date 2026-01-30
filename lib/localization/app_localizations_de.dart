// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get filterWindows => 'Filter windows';

  @override
  String get favoriteButtonTooltipAdd => 'Add to favorites';

  @override
  String get favoriteButtonTooltipRemove => 'Remove from favorites';

  @override
  String get suspendAllInstances => 'Suspend all instances';

  @override
  String get resumeAllInstances => 'Resume all instances';

  @override
  String get close => 'Close';

  @override
  String get detailsDialogTitle => 'Details';

  @override
  String get detailsDialogWindowTitle => 'Fenstertitel';

  @override
  String get detailsDialogExecutableName => 'Ausführbarer Name';

  @override
  String get detailsDialogPID => 'PID';

  @override
  String get detailsDialogCurrentStatus => 'Aktueller Status';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get copyLogs => 'Protokolle kopieren';

  @override
  String get logsCopiedNotification => 'Protokolle kopiert!';

  @override
  String get donate => 'Spenden';

  @override
  String get donateMessage =>
      'Wenn Sie diese App nützlich finden, können Sie uns mit einer Spende unterstützen.';

  @override
  String get madeBy => 'Mit 💙 gemacht von ';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get behaviourTitle => 'Verhalten';

  @override
  String get autoRefresh => 'Automatische Aktualisierung';

  @override
  String get autoRefreshDescription => 'Automatische Aktualisierung der Daten';

  @override
  String get autoRefreshInterval => 'Intervall der automatischen Aktualisierung';

  @override
  String autoRefreshIntervalAmount(int interval) {
    return '$interval Sekunden';
  }

  @override
  String get closeToTray => 'Schließen Sie das Fenster in den Systembereich';

  @override
  String get minimizeAndRestoreWindows => 'Minimieren und Wiederherstellen von Fenstern';

  @override
  String get pinSuspendedWindows => 'Pin suspended windows';

  @override
  String get pinSuspendedWindowsTooltip =>
      'If enabled, suspended windows will always be shown at the top of the window list.';

  @override
  String get showHiddenWindows => 'Versteckte Fenster anzeigen';

  @override
  String get showHiddenWindowsTooltip =>
      'Schließen Sie Fenster ein, die normalerweise ausgeblendet sind.';

  @override
  String get themeTitle => 'Thema';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';

  @override
  String get pitchBlack => 'Pechschwarz';

  @override
  String get systemIntegrationTitle => 'Systemintegration';

  @override
  String get startAutomatically => 'Starten Sie die App automatisch mit dem System';

  @override
  String get startInTray => 'Starten Sie die App im Systembereich';

  @override
  String get troubleshootingTitle => 'Fehlerbehebung';

  @override
  String get logs => 'Protokolle';

  @override
  String get verboseLogging => 'Verbose logging';

  @override
  String get aboutTitle => 'Über';

  @override
  String get version => 'Nyrna Version';

  @override
  String get homepage => 'Nyrna Homepage';

  @override
  String get repository => 'GitHub Repository';

  @override
  String get hotkey => 'Hotkey';

  @override
  String get recordNewHotkey => 'Record a new hotkey';

  @override
  String get appSpecificHotkeys => 'App specific hotkeys';

  @override
  String get appSpecificHotkeysTooltip =>
      'Hotkeys to directly toggle suspend/resume for specific apps, even when they are not focused.';

  @override
  String get addAppSpecificHotkey => 'Add app specific hotkey';

  @override
  String get selectApp => 'Select app';
}
