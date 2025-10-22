import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sv')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Crafta'**
  String get appTitle;

  /// Welcome message shown to users
  ///
  /// In en, this message translates to:
  /// **'Welcome to Crafta! I\'m here to help you create amazing creatures and furniture for Minecraft!'**
  String get welcomeMessage;

  /// Title of the creator screen
  ///
  /// In en, this message translates to:
  /// **'Crafta Creator'**
  String get creatorTitle;

  /// Instruction for voice input
  ///
  /// In en, this message translates to:
  /// **'Hold to speak'**
  String get holdToSpeak;

  /// Text shown when listening for voice input
  ///
  /// In en, this message translates to:
  /// **'Listening... Speak now!'**
  String get listening;

  /// Placeholder text for text input
  ///
  /// In en, this message translates to:
  /// **'Type what you want to create...'**
  String get typeToCreate;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Loading message when creating
  ///
  /// In en, this message translates to:
  /// **'Creating your creature...'**
  String get creating;

  /// Additional loading message
  ///
  /// In en, this message translates to:
  /// **'This might take a moment...'**
  String get thisMightTakeMoment;

  /// Success message when creating creature
  ///
  /// In en, this message translates to:
  /// **'Great! Creating your {creatureType}...'**
  String greatCreating(String creatureType);

  /// Message when more information is needed
  ///
  /// In en, this message translates to:
  /// **'Got it! Tell me more about your creature...'**
  String get gotItTellMeMore;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again!'**
  String get somethingWentWrong;

  /// Message when suggestion is loaded
  ///
  /// In en, this message translates to:
  /// **'Suggestion loaded: {suggestion}'**
  String suggestionLoaded(String suggestion);

  /// Message when suggestion is tapped
  ///
  /// In en, this message translates to:
  /// **'Great idea! Let\'s create that!'**
  String get greatIdeaLetsCreate;

  /// Button text for sending to Minecraft
  ///
  /// In en, this message translates to:
  /// **'Send to Minecraft'**
  String get sendToMinecraft;

  /// Text shown when exporting
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// Success message for export
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully!'**
  String get exportCompleted;

  /// Error message for export
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailed;

  /// Button text for creating another
  ///
  /// In en, this message translates to:
  /// **'Make Another'**
  String get makeAnother;

  /// Instruction for suggestion tap
  ///
  /// In en, this message translates to:
  /// **'Tap to create!'**
  String get tapToCreate;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Swedish language option
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get swedish;

  /// Title for parent settings screen
  ///
  /// In en, this message translates to:
  /// **'Parent Settings'**
  String get parentSettings;

  /// Age group setting label
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// Safety level setting label
  ///
  /// In en, this message translates to:
  /// **'Safety Level'**
  String get safetyLevel;

  /// Functionality switches section title
  ///
  /// In en, this message translates to:
  /// **'Functionality Switches'**
  String get functionalitySwitches;

  /// Voice settings section title
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// Creation history section title
  ///
  /// In en, this message translates to:
  /// **'Creation History'**
  String get creationHistory;

  /// Export management section title
  ///
  /// In en, this message translates to:
  /// **'Export Management'**
  String get exportManagement;

  /// Legal and privacy settings section title
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy Settings'**
  String get legalPrivacySettings;

  /// Save settings button text
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// Speech recognition toggle label
  ///
  /// In en, this message translates to:
  /// **'Speech Recognition'**
  String get speechEnabled;

  /// Text-to-speech toggle label
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get ttsEnabled;

  /// AI features toggle label
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiEnabled;

  /// Export features toggle label
  ///
  /// In en, this message translates to:
  /// **'Export Features'**
  String get exportEnabled;

  /// Creation history toggle label
  ///
  /// In en, this message translates to:
  /// **'Creation History'**
  String get historyEnabled;

  /// Age group 4-6 years option
  ///
  /// In en, this message translates to:
  /// **'4-6 years'**
  String get ageGroup46;

  /// Age group 7-8 years option
  ///
  /// In en, this message translates to:
  /// **'7-8 years'**
  String get ageGroup78;

  /// Age group 9-10 years option
  ///
  /// In en, this message translates to:
  /// **'9-10 years'**
  String get ageGroup910;

  /// High safety level option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get safetyLevelHigh;

  /// Medium safety level option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get safetyLevelMedium;

  /// Low safety level option
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get safetyLevelLow;

  /// Tutorial welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Crafta!'**
  String get tutorialWelcome;

  /// Tutorial welcome description
  ///
  /// In en, this message translates to:
  /// **'I\'m your AI friend who helps you create amazing Minecraft creatures!'**
  String get tutorialWelcomeDesc;

  /// Tutorial welcome action
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and say \"Hello Crafta!\"'**
  String get tutorialWelcomeAction;

  /// Tutorial voice training title
  ///
  /// In en, this message translates to:
  /// **'Voice Training'**
  String get tutorialVoiceTraining;

  /// Tutorial voice training description
  ///
  /// In en, this message translates to:
  /// **'Speak clearly so I can understand you better. Try saying your name!'**
  String get tutorialVoiceTrainingDesc;

  /// Tutorial voice training action
  ///
  /// In en, this message translates to:
  /// **'Say \"My name is [your name]\"'**
  String get tutorialVoiceTrainingAction;

  /// Tutorial first creature title
  ///
  /// In en, this message translates to:
  /// **'Create Your First Creature'**
  String get tutorialFirstCreature;

  /// Tutorial first creature description
  ///
  /// In en, this message translates to:
  /// **'Let\'s create something amazing together! Try asking for a friendly dragon.'**
  String get tutorialFirstCreatureDesc;

  /// Tutorial first creature action
  ///
  /// In en, this message translates to:
  /// **'Say \"Create a friendly dragon\"'**
  String get tutorialFirstCreatureAction;

  /// Tutorial customize title
  ///
  /// In en, this message translates to:
  /// **'Customize Your Creature'**
  String get tutorialCustomize;

  /// Tutorial customize description
  ///
  /// In en, this message translates to:
  /// **'Make it special! Try asking for different colors or effects.'**
  String get tutorialCustomizeDesc;

  /// Tutorial customize action
  ///
  /// In en, this message translates to:
  /// **'Say \"Make it blue with sparkles\"'**
  String get tutorialCustomizeAction;

  /// Tutorial view 3D title
  ///
  /// In en, this message translates to:
  /// **'View in 3D'**
  String get tutorialView3D;

  /// Tutorial view 3D description
  ///
  /// In en, this message translates to:
  /// **'See how your creature looks in Minecraft! Tap the 3D button.'**
  String get tutorialView3DDesc;

  /// Tutorial view 3D action
  ///
  /// In en, this message translates to:
  /// **'Tap the \"VIEW IN 3D\" button'**
  String get tutorialView3DAction;

  /// Tutorial export title
  ///
  /// In en, this message translates to:
  /// **'Export to Minecraft'**
  String get tutorialExport;

  /// Tutorial export description
  ///
  /// In en, this message translates to:
  /// **'Ready to use your creature in Minecraft? Let\'s export it!'**
  String get tutorialExportDesc;

  /// Tutorial export action
  ///
  /// In en, this message translates to:
  /// **'Tap \"Export to Minecraft\"'**
  String get tutorialExportAction;

  /// Tutorial complete title
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get tutorialComplete;

  /// Tutorial complete description
  ///
  /// In en, this message translates to:
  /// **'Amazing! You\'ve learned how to use Crafta. Now create anything you can imagine!'**
  String get tutorialCompleteDesc;

  /// Tutorial complete action
  ///
  /// In en, this message translates to:
  /// **'Start creating!'**
  String get tutorialCompleteAction;

  /// Tutorial previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get tutorialPrevious;

  /// Tutorial skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// Tutorial try it button
  ///
  /// In en, this message translates to:
  /// **'Try It!'**
  String get tutorialTryIt;

  /// Tutorial next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// Tutorial complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get tutorialCompleteButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sv': return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
