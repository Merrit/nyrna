import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('it')
  ];

  /// Label for a cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for a confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Hint text for searchbox that allows the user to filter windows
  ///
  /// In en, this message translates to:
  /// **'Filter windows'**
  String get filterWindows;

  /// Tooltip for the add to favorites button
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteButtonTooltipAdd;

  /// Tooltip for the remove from favorites button
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoriteButtonTooltipRemove;

  /// The title of the details dialog
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsDialogTitle;

  /// Label for the window title field in the details dialog
  ///
  /// In en, this message translates to:
  /// **'Window Title'**
  String get detailsDialogWindowTitle;

  /// Label for the executable name field in the details dialog
  ///
  /// In en, this message translates to:
  /// **'Executable Name'**
  String get detailsDialogExecutableName;

  /// Label for the PID field in the details dialog
  ///
  /// In en, this message translates to:
  /// **'PID'**
  String get detailsDialogPID;

  /// Label for the current status field in the details dialog
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get detailsDialogCurrentStatus;

  /// Label for the copy logs button
  ///
  /// In en, this message translates to:
  /// **'Copy logs'**
  String get copyLogs;

  /// Notification displayed when logs are copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get logsCopiedNotification;

  /// Label for the donate button
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// Message displayed on the donate page
  ///
  /// In en, this message translates to:
  /// **'If you like this application, please consider donating to support its development.'**
  String get donateMessage;

  /// Introduction to application author
  ///
  /// In en, this message translates to:
  /// **'Made with 💙 by '**
  String get madeBy;

  /// The title of the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// The title of the behaviour section of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get behaviourTitle;

  /// Label for the auto refresh setting
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh'**
  String get autoRefresh;

  /// Description for the auto refresh setting
  ///
  /// In en, this message translates to:
  /// **'Update window & process info automatically'**
  String get autoRefreshDescription;

  /// Label for the auto refresh interval setting
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh Interval'**
  String get autoRefreshInterval;

  /// The amount of time between auto refreshes
  ///
  /// In en, this message translates to:
  /// **'{interval} seconds'**
  String autoRefreshIntervalAmount(int interval);

  /// Label for the close to tray setting
  ///
  /// In en, this message translates to:
  /// **'Close to tray'**
  String get closeToTray;

  /// Label for the minimize / restore windows setting
  ///
  /// In en, this message translates to:
  /// **'Minimize / restore windows'**
  String get minimizeAndRestoreWindows;

  /// Whether to pin suspended windows to the top of the window list
  ///
  /// In en, this message translates to:
  /// **'Pin suspended windows'**
  String get pinSuspendedWindows;

  /// Tooltip for the pin suspended windows setting
  ///
  /// In en, this message translates to:
  /// **'If enabled, suspended windows will always be shown at the top of the window list.'**
  String get pinSuspendedWindowsTooltip;

  /// Label for the show hidden windows setting
  ///
  /// In en, this message translates to:
  /// **'Show hidden windows'**
  String get showHiddenWindows;

  /// Tooltip for the show hidden windows setting
  ///
  /// In en, this message translates to:
  /// **'Includes windows from other virtual desktops and special windows that are not normally detected.'**
  String get showHiddenWindowsTooltip;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// Label for the dark theme setting
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Label for the light theme setting
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Label for the pitch black theme setting
  ///
  /// In en, this message translates to:
  /// **'Pitch Black'**
  String get pitchBlack;

  /// The title of the system integration section of the settings page.
  ///
  /// In en, this message translates to:
  /// **'System Integration'**
  String get systemIntegrationTitle;

  /// Label for the start automatically at system boot setting
  ///
  /// In en, this message translates to:
  /// **'Start automatically at system boot'**
  String get startAutomatically;

  /// Label for the start hidden in system tray setting
  ///
  /// In en, this message translates to:
  /// **'Start hidden in system tray'**
  String get startInTray;

  /// The title of the troubleshooting section of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshootingTitle;

  /// Label for the logs button
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// The title of the about section of the settings page.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Label for the version number
  ///
  /// In en, this message translates to:
  /// **'Nyrna version'**
  String get version;

  /// Label for the homepage link
  ///
  /// In en, this message translates to:
  /// **'Nyrna homepage'**
  String get homepage;

  /// Label for the repository link
  ///
  /// In en, this message translates to:
  /// **'GitHub repository'**
  String get repository;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
