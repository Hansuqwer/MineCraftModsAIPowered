import 'package:flutter/material.dart';

/// App localization service for multi-language support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common
  String get appName => _translate('Crafta', 'Crafta');
  String get ok => _translate('OK', 'OK');
  String get cancel => _translate('Cancel', 'Avbryt');
  String get save => _translate('Save', 'Spara');
  String get delete => _translate('Delete', 'Ta bort');
  String get send => _translate('Send', 'Skicka');
  String get back => _translate('Back', 'Tillbaka');
  String get next => _translate('Next', 'Nästa');
  String get done => _translate('Done', 'Klar');

  // Welcome Screen
  String get welcomeTitle => _translate('Welcome to Crafta!', 'Välkommen till Crafta!');
  String get welcomeSubtitle => _translate(
    'Create amazing creatures with AI!',
    'Skapa fantastiska varelser med AI!'
  );
  String get getStarted => _translate('Get Started', 'Kom igång');
  String get parentSettings => _translate('Parent Settings', 'Föräldra­inställningar');

  // Creator Screen
  String get creatorTitle => _translate('Crafta Creator', 'Crafta Skapare');
  String get craftaGreeting => _translate(
    'Hi! I\'m Crafta! What would you like to create today?',
    'Hej! Jag är Crafta! Vad vill du skapa idag?'
  );
  String get listening => _translate('Listening...', 'Lyssnar...');
  String get tapAndHold => _translate(
    'Tap and hold to speak',
    'Håll inne för att prata'
  );
  String get tapToSpeak => _translate(
    'Tap and hold the microphone to talk to Crafta',
    'Håll inne på mikrofonen för att prata med Crafta'
  );
  String get orTypeMessage => _translate('Or type your message:', 'Eller skriv ditt meddelande:');
  String get typeHere => _translate(
    'Describe what you want to create...',
    'Beskriv vad du vill skapa...'
  );
  String get creating => _translate('Creating your creature...', 'Skapar din varelse...');

  // Advanced Customization
  String get advancedCustomization => _translate(
    'Advanced Customization',
    'Avancerad anpassning'
  );
  String get advancedCustomizationAvailable => _translate(
    '🎨 Advanced Customization Available!',
    '🎨 Avancerad anpassning tillgänglig!'
  );
  String get customizeOptions => _translate(
    'Customize colors, size, personality, abilities, and accessories',
    'Anpassa färger, storlek, personlighet, förmågor och tillbehör'
  );
  String get customize => _translate('Customize', 'Anpassa');
  String get comingSoon => _translate('Coming Soon!', 'Kommer snart!');
  String get comingSoonDescription => _translate(
    'Advanced customization features are under development.\n\nFor now, you can create amazing creatures using voice or text input!',
    'Avancerade anpassningsfunktioner är under utveckling.\n\nFör tillfället kan du skapa fantastiska varelser med röst eller text!'
  );
  String get goBack => _translate('Go Back', 'Gå tillbaka');

  // Complete Screen
  String get creationReady => _translate(
    'Your Creation is Ready!',
    'Din skapelse är klar!'
  );
  String get amazing => _translate('Amazing!', 'Fantastiskt!');
  String get readyForMinecraft => _translate(
    'Your creation is ready to go to Minecraft!',
    'Din skapelse är redo för Minecraft!'
  );
  String get shareCreature => _translate('Share Creature', 'Dela varelse');
  String get exportToMinecraft => _translate(
    'Export to Minecraft',
    'Exportera till Minecraft'
  );
  String get makeAnother => _translate('Make Another', 'Skapa en till');
  String get nextCreature => _translate('Next Creature', 'Nästa varelse');
  String get tryThisNext => _translate('Try this next:', 'Prova detta härnäst:');
  String get tapToCreate => _translate('Tap to create!', 'Tryck för att skapa!');

  // Settings
  String get settings => _translate('Settings', 'Inställningar');
  String get language => _translate('Language', 'Språk');
  String get selectLanguage => _translate('Select Language', 'Välj språk');
  String get childAge => _translate('Child Age', 'Barnets ålder');
  String get voiceSettings => _translate('Voice Settings', 'Röstinställningar');
  String get aiSettings => _translate('AI Settings', 'AI-inställningar');
  String get minecraftSettings => _translate(
    'Minecraft Settings',
    'Minecraft-inställningar'
  );

  // Parent Settings
  String get safetyFirst => _translate('Safety First!', 'Säkerhet först!');
  String get craftaIsSafe => _translate(
    'Crafta is designed with safety in mind. All content is age-appropriate and moderated.',
    'Crafta är designad med säkerhet i åtanke. Allt innehåll är åldersanpassat och modererat.'
  );
  String get ageGroup => _translate('Age Group', 'Åldersgrupp');
  String get safetyLevel => _translate('Safety Level', 'Säkerhetsnivå');
  String get high => _translate('High', 'Hög');
  String get medium => _translate('Medium', 'Medel');
  String get low => _translate('Low', 'Låg');
  String get featureToggles => _translate('Feature Toggles', 'Funktionsväxlingar');
  String get speechRecognition => _translate('Speech Recognition', 'Taligenkänning');
  String get textToSpeech => _translate('Text-to-Speech', 'Text-till-tal');
  String get aiCreation => _translate('AI Creation', 'AI-skapande');
  String get minecraftExportFeature => _translate('Minecraft Export', 'Minecraft Export');
  String get creationHistory => _translate('Creation History', 'Skapelsehistorik');
  String get viewHistory => _translate('View History', 'Visa historik');
  String get clearHistory => _translate('Clear History', 'Rensa historik');
  String get aiProviderStatus => _translate('AI Provider Status', 'AI-leverantörstatus');
  String get viewStatus => _translate('View Status', 'Visa status');

  // Errors
  String get errorOccurred => _translate('An error occurred', 'Ett fel uppstod');
  String get tryAgain => _translate('Try again', 'Försök igen');
  String get noInternet => _translate(
    'No internet connection',
    'Ingen internetanslutning'
  );
  String get offlineMode => _translate('Offline Mode', 'Offlineläge');

  // AI Responses (Personality)
  String get aiCreating => _translate(
    'Let me create that for you!',
    'Låt mig skapa det åt dig!'
  );
  String get aiExcited => _translate(
    'Wow! That sounds amazing!',
    'Wow! Det låter fantastiskt!'
  );
  String get aiEncouragement => _translate(
    'Great job! What else can we create?',
    'Bra jobbat! Vad mer kan vi skapa?'
  );

  // Welcome screen features
  String get voiceFirst => _translate('Voice-First', 'Röststyrd');
  String get voiceFirstDesc => _translate('Talk to create!', 'Prata för att skapa!');
  String get aiPowered => _translate('AI-Powered', 'AI-Driven');
  String get aiPoweredDesc => _translate('Magic creativity!', 'Magisk kreativitet!');
  String get minecraftExport => _translate('Minecraft Export', 'Minecraft Export');
  String get minecraftExportDesc => _translate('Play with your creatures!', 'Spela med dina varelser!');

  // Quick tips
  String get quickTips => _translate('Quick Tips', 'Snabbtips');
  String get tip1 => _translate('Hold the microphone to speak', 'Håll mikrofonen för att prata');
  String get tip2 => _translate('Describe colors, size, and abilities', 'Beskriv färger, storlek och förmågor');
  String get tip3 => _translate('Try "dragon with fire" or "rainbow unicorn"', 'Prova "drake med eld" eller "regnbågs enhörning"');

  // Helper method for translation
  String _translate(String en, String sv) {
    return locale.languageCode == 'sv' ? sv : en;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sv'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
