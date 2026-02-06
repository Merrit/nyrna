// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get cancel => 'Cancella';

  @override
  String get confirm => 'Conferma';

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
  String get detailsDialogTitle => 'Dettagli';

  @override
  String get detailsDialogWindowTitle => 'Titolo finestra';

  @override
  String get detailsDialogExecutableName => 'Nome eseguibile';

  @override
  String get detailsDialogPID => 'PID';

  @override
  String get detailsDialogCurrentStatus => 'Stato attuale';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get copyLogs => 'Copia log';

  @override
  String get logsCopiedNotification => 'Log copiati negli appunti';

  @override
  String get donate => 'Donazione';

  @override
  String get donateMessage =>
      'Se ti piace questa applicazione, considera la possibilità di fare una donazione per sostenerne lo sviluppo.';

  @override
  String get madeBy => 'Fatto con il 💙 da ';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get behaviourTitle => 'Comportamento';

  @override
  String get autoRefresh => 'Aggiornamento automatico';

  @override
  String get autoRefreshDescription =>
      'Aggiorna automaticamente le informazioni sulla finestra e sul processo';

  @override
  String get autoRefreshInterval => 'Intervallo di aggiornamento automatico';

  @override
  String autoRefreshIntervalAmount(int interval) {
    return '$interval secondi';
  }

  @override
  String get closeToTray => 'Vicino alla barra delle applicazioni';

  @override
  String get minimizeAndRestoreWindows => 'Minimizza / ripristina finestre';

  @override
  String get pinSuspendedWindows => 'Pin suspended windows';

  @override
  String get pinSuspendedWindowsTooltip =>
      'If enabled, suspended windows will always be shown at the top of the window list.';

  @override
  String get showHiddenWindows => 'Mostra finestre nascoste';

  @override
  String get showHiddenWindowsTooltip =>
      'Include finestre di altri desktop virtuali e finestre speciali che normalmente non vengono rilevate.';

  @override
  String get personalizationTitle => 'Personalizzazione';

  @override
  String get hidePidSetting => 'Nascondi PID';

  @override
  String get hidePidSettingDescription => 'Non mostrare il PID nelle schede dei processi.';

  @override
  String get exeFirstSetting => 'Nome eseguibile in cima';

  @override
  String get exeFirstSettingDescription =>
      'Mostra sempre il nome dell\'eseguibile in alto sulla scheda.';

  @override
  String get limitWindowTitleToOneLine => 'Limita il titolo a una riga';

  @override
  String get limitWindowTitleToOneLineDescription =>
      'Tronca titoli lunghi con ellissi per mantenere un\'altezza uniforme.';

  @override
  String get themeTitle => 'Tema';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get pitchBlack => 'Nero pece';

  @override
  String get systemIntegrationTitle => 'Integrazione del sistema';

  @override
  String get startAutomatically => 'Avvia automaticamente all\'avvio del sistema';

  @override
  String get startInTray => 'Avvia nascosto nella barra delle applicazioni';

  @override
  String get troubleshootingTitle => 'Risoluzione dei problemi';

  @override
  String get logs => 'Log';

  @override
  String get verboseLogging => 'Verbose logging';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get version => 'Versione di Nyrna';

  @override
  String get homepage => 'Homepage di Nyrna';

  @override
  String get repository => 'Repository GitHub';

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
