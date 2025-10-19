import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'language_service.dart';

class TTSService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  
  // Sound effects for delightful interactions
  static const String _celebrationSound = '🎉';
  static const String _sparkleSound = '✨';
  static const String _magicSound = '🌟';

  /// Initialize TTS
  Future<bool> initialize() async {
    // On desktop platforms, TTS may not be available
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print('TTS not available on desktop platforms');
      _isInitialized = false;
      return false;
    }

    _flutterTts = FlutterTts();
    
    try {
      // Get current language from settings
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      // Set language based on current locale
      if (languageCode == 'sv') {
        await _flutterTts!.setLanguage('sv-SE'); // Swedish
      } else {
        await _flutterTts!.setLanguage('en-US'); // English (default)
      }
      
      // Configure for warm, friendly, child-friendly voice
      await _flutterTts!.setSpeechRate(0.6); // Slightly faster but still clear for kids
      await _flutterTts!.setVolume(0.9); // Slightly softer for warmth
      await _flutterTts!.setPitch(1.2); // Higher pitch for friendliness
      
      // Set voice characteristics for warmth
      if (Platform.isAndroid) {
        // Try to use a more natural voice on Android
        await _flutterTts!.setEngine('com.google.android.tts');
        await _flutterTts!.setLanguage(languageCode == 'sv' ? 'sv-SE' : 'en-US');
      }
      
      // Set voice parameters for personality
      await _flutterTts!.setLanguage(languageCode == 'sv' ? 'sv-SE' : 'en-US');
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('TTS initialization error: $e');
      return false;
    }
  }

  /// Speak the given text with personality
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('TTS not initialized');
      return;
    }

    try {
      // Add personality to the text
      final enhancedText = await _addPersonalityToText(text);
      await _flutterTts!.speak(enhancedText);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  /// Add personality and warmth to text
  Future<String> _addPersonalityToText(String text) async {
    // Get current language
    final currentLocale = await LanguageService.getCurrentLanguage();
    final isSwedish = currentLocale.languageCode == 'sv';
    
    // Add warm, friendly expressions
    if (text.toLowerCase().contains('created') || text.toLowerCase().contains('skapade')) {
      if (isSwedish) {
        return '🎉 Wow! $text Det blev fantastiskt! 🎉';
      } else {
        return '🎉 Wow! $text That turned out amazing! 🎉';
      }
    }
    
    if (text.toLowerCase().contains('dragon') || text.toLowerCase().contains('drake')) {
      if (isSwedish) {
        return '🐉 $text Rååå! Vilken cool drake! 🐉';
      } else {
        return '🐉 $text Rawr! What a cool dragon! 🐉';
      }
    }
    
    if (text.toLowerCase().contains('magic') || text.toLowerCase().contains('magisk')) {
      if (isSwedish) {
        return '✨ $text Så magiskt! ✨';
      } else {
        return '✨ $text So magical! ✨';
      }
    }
    
    if (text.toLowerCase().contains('color') || text.toLowerCase().contains('färg')) {
      if (isSwedish) {
        return '🌈 $text Vilka vackra färger! 🌈';
      } else {
        return '🌈 $text What beautiful colors! 🌈';
      }
    }
    
    // Default warm response
    if (isSwedish) {
      return '🌟 $text Så roligt att skapa med dig! 🌟';
    } else {
      return '🌟 $text So fun creating with you! 🌟';
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts!.stop();
    }
  }

  /// Check if TTS is available
  bool get isAvailable => _isInitialized;
  
  /// Play celebration sound effect
  Future<void> playCelebrationSound() async {
    if (!_isInitialized) return;
    
    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🎉 Fantastiskt! Så bra gjort! 🎉' : '🎉 Amazing! 🎉';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Celebration sound error: $e');
    }
  }
  
  /// Play sparkle sound effect
  Future<void> playSparkleSound() async {
    if (!_isInitialized) return;
    
    try {
      // Play sparkle sound with TTS
      await _flutterTts!.speak('✨ Sparkles! ✨');
    } catch (e) {
      print('Sparkle sound error: $e');
    }
  }
  
  /// Play magic sound effect
  Future<void> playMagicSound() async {
    if (!_isInitialized) return;
    
    try {
      // Play magic sound with TTS
      await _flutterTts!.speak('🌟 Magic! 🌟');
    } catch (e) {
      print('Magic sound error: $e');
    }
  }
  
  /// Play delightful welcome sound
  Future<void> playWelcomeSound() async {
    if (!_isInitialized) return;
    
    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🌈 Välkommen till Crafta! 🌈' : '🌈 Welcome to Crafta! 🌈';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Welcome sound error: $e');
    }
  }
  
  /// Play creation complete sound
  Future<void> playCreationCompleteSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🎨 Din skapelse är klar! 🎨' : '🎨 Your creation is ready! 🎨';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Creation complete sound error: $e');
    }
  }

  /// Play thinking sound
  Future<void> playThinkingSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🤔 Låt mig tänka... 🤔' : '🤔 Let me think... 🤔';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Thinking sound error: $e');
    }
  }

  /// Play success sound
  Future<void> playSuccessSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🎉 Framgång! 🎉' : '🎉 Success! 🎉';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Success sound error: $e');
    }
  }

  /// Play error sound
  Future<void> playErrorSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '😅 Hoppsan, låt oss försöka igen! 😅' : '😅 Oops, let\'s try again! 😅';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Error sound error: $e');
    }
  }

  /// Play loading sound
  Future<void> playLoadingSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '⏳ Skapar din varelse... ⏳' : '⏳ Creating your creature... ⏳';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Loading sound error: $e');
    }
  }

  /// Play creature sound based on type
  Future<void> playCreatureSound(String creatureType) async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      final isSwedish = languageCode == 'sv';
      
      String sound = '';
      switch (creatureType.toLowerCase()) {
        // Creatures
        case 'dragon':
        case 'drake':
          sound = isSwedish ? '🐉 Rååå! Jag är en vänlig drake! 🐉' : '🐉 Rawr! I\'m a friendly dragon! 🐉';
          break;
        case 'unicorn':
        case 'enhörning':
          sound = isSwedish ? '🦄 Gnägg! Jag är en magisk enhörning! 🦄' : '🦄 Neigh! I\'m a magical unicorn! 🦄';
          break;
        case 'phoenix':
          sound = '🔥 Squawk! I\'m a phoenix! 🔥';
          break;
        case 'griffin':
          sound = '🦅 Screech! I\'m a griffin! 🦅';
          break;
        case 'cat':
        case 'katt':
          sound = isSwedish ? '🐱 Mjau! Jag är en magisk katt! 🐱' : '🐱 Meow! I\'m a magical cat! 🐱';
          break;
        case 'dog':
        case 'hund':
          sound = isSwedish ? '🐶 Voff! Jag är en magisk hund! 🐶' : '🐶 Woof! I\'m a magical dog! 🐶';
          break;
        case 'horse':
          sound = '🐴 Neigh! I\'m a magical horse! 🐴';
          break;
        case 'sheep':
          sound = '🐑 Baa! I\'m a magical sheep! 🐑';
          break;
        case 'pig':
          sound = '🐷 Oink! I\'m a magical pig! 🐷';
          break;
        case 'chicken':
          sound = '🐔 Cluck! I\'m a magical chicken! 🐔';
          break;
        case 'cow':
        case 'ko':
          sound = isSwedish ? '🐄 Mu! Jag är en magisk ko! 🐄' : '🐄 Moo! I\'m a magical cow! 🐄';
          break;
        case 'pig':
        case 'gris':
          sound = isSwedish ? '🐷 Nöff! Jag är en magisk gris! 🐷' : '🐷 Oink! I\'m a magical pig! 🐷';
          break;
        case 'sheep':
        case 'får':
          sound = isSwedish ? '🐑 Bä! Jag är ett magiskt får! 🐑' : '🐑 Baa! I\'m a magical sheep! 🐑';
          break;
        case 'chicken':
        case 'höna':
          sound = isSwedish ? '🐔 Kuckeliku! Jag är en magisk höna! 🐔' : '🐔 Cluck! I\'m a magical chicken! 🐔';
          break;
        // Weapons and items
        case 'sword':
          sound = '⚔️ Clang! I\'m a magical sword! ⚔️';
          break;
        case 'axe':
          sound = '🪓 Chop! I\'m a powerful axe! 🪓';
          break;
        case 'bow':
          sound = '🏹 Twang! I\'m a magical bow! 🏹';
          break;
        case 'shield':
          sound = '🛡️ Clang! I\'m a protective shield! 🛡️';
          break;
        case 'wand':
          sound = '🪄 Zap! I\'m a magic wand! 🪄';
          break;
        case 'staff':
          sound = '🪄 Whoosh! I\'m a magical staff! 🪄';
          break;
        case 'hammer':
          sound = '🔨 Bang! I\'m a mighty hammer! 🔨';
          break;
        case 'spear':
          sound = '🗡️ Thrust! I\'m a sharp spear! 🗡️';
          break;
        case 'dagger':
          sound = '🗡️ Slice! I\'m a quick dagger! 🗡️';
          break;
        case 'mace':
          sound = '🔨 Smash! I\'m a heavy mace! 🔨';
          break;
        default:
          sound = '🌟 Hello! I\'m your magical creation! 🌟';
      }
      
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Creature sound error: $e');
    }
  }

  /// Play ambient background sound
  Future<void> playAmbientSound() async {
    if (!_isInitialized) return;

    try {
      // Get current language
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      String sound = languageCode == 'sv' ? '🌟 Välkommen till Craftas magiska värld! 🌟' : '🌟 Welcome to the magical world of Crafta! 🌟';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Ambient sound error: $e');
    }
  }

  /// Play funny, warm welcome message
  Future<void> playWarmWelcome() async {
    if (!_isInitialized) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      final welcomeMessages = languageCode == 'sv' ? [
        '🎨 Hej där, kreativa vän! Jag är Crafta och jag älskar att skapa med dig! 🎨',
        '🌟 Välkommen till vår magiska verkstad! Låt oss skapa något fantastiskt tillsammans! 🌟',
        '🌈 Hej! Jag är så glad att du är här! Låt oss ha kul och skapa! 🌈',
        '✨ Välkommen, min kreativa vän! Jag kan inte vänta på att se vad vi ska skapa! ✨',
        '🎉 Hej hej! Jag är Crafta och jag älskar att skapa varelser! Vad ska vi göra idag? 🎉'
      ] : [
        '🎨 Hey there, creative friend! I\'m Crafta and I love creating with you! 🎨',
        '🌟 Welcome to our magical workshop! Let\'s create something amazing together! 🌟',
        '🌈 Hi! I\'m so happy you\'re here! Let\'s have fun and create! 🌈',
        '✨ Welcome, my creative friend! I can\'t wait to see what we\'ll create! ✨',
        '🎉 Hey hey! I\'m Crafta and I love creating creatures! What should we make today? 🎉'
      ];
      
      final randomMessage = welcomeMessages[DateTime.now().millisecond % welcomeMessages.length];
      await _flutterTts!.speak(randomMessage);
    } catch (e) {
      print('Warm welcome error: $e');
    }
  }

  /// Play funny encouragement message
  Future<void> playEncouragement() async {
    if (!_isInitialized) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      final encouragementMessages = languageCode == 'sv' ? [
        '🎉 Fantastiskt jobbat! Du är så kreativ! 🎉',
        '🌟 Wow! Det där var verkligen imponerande! 🌟',
        '✨ Du har en sådan fantastisk fantasi! ✨',
        '🌈 Vilken cool idé! Du är verkligen en konstnär! 🌈',
        '🎨 Så bra! Du lär dig snabbt! 🎨',
        '🦄 Du skapar de vackraste varelser! 🦄',
        '🐉 Vilken fantastisk drake! Du är så duktig! 🐉',
        '✨ Magiskt! Du har verkligen talang! ✨'
      ] : [
        '🎉 Amazing job! You\'re so creative! 🎉',
        '🌟 Wow! That was really impressive! 🌟',
        '✨ You have such an amazing imagination! ✨',
        '🌈 What a cool idea! You\'re really an artist! 🌈',
        '🎨 So good! You learn so fast! 🎨',
        '🦄 You create the most beautiful creatures! 🦄',
        '🐉 What an amazing dragon! You\'re so talented! 🐉',
        '✨ Magical! You really have talent! ✨'
      ];
      
      final randomMessage = encouragementMessages[DateTime.now().millisecond % encouragementMessages.length];
      await _flutterTts!.speak(randomMessage);
    } catch (e) {
      print('Encouragement error: $e');
    }
  }

  /// Play funny thinking sound
  Future<void> playFunnyThinking() async {
    if (!_isInitialized) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      
      final thinkingMessages = languageCode == 'sv' ? [
        '🤔 Hmm, låt mig tänka... Vad ska vi skapa? 🤔',
        '🧠 Ooh, jag får en idé! Vänta lite... 🧠',
        '💭 Låt mig fundera... Det här blir spännande! 💭',
        '🤯 Wow, så många möjligheter! Vad väljer vi? 🤯',
        '🎯 Aha! Jag vet precis vad vi ska göra! 🎯'
      ] : [
        '🤔 Hmm, let me think... What should we create? 🤔',
        '🧠 Ooh, I\'m getting an idea! Just wait... 🧠',
        '💭 Let me ponder... This is going to be exciting! 💭',
        '🤯 Wow, so many possibilities! What do we choose? 🤯',
        '🎯 Aha! I know exactly what we should do! 🎯'
      ];
      
      final randomMessage = thinkingMessages[DateTime.now().millisecond % thinkingMessages.length];
      await _flutterTts!.speak(randomMessage);
    } catch (e) {
      print('Funny thinking error: $e');
    }
  }

  /// Play funny surprise sound
  Future<void> playFunnySurprise() async {
    if (!_isInitialized) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;

      final surpriseMessages = languageCode == 'sv' ? [
        '😲 Oj! Det där var oväntat! Så coolt! 😲',
        '🤯 Wow! Det här blir verkligen fantastiskt! 🤯',
        '😍 Åh! Jag älskar det här! Så vackert! 😍',
        '🎊 Fantastiskt! Det här är verkligen magiskt! 🎊',
        '🌟 Omg! Det här är så coolt! Jag är imponerad! 🌟'
      ] : [
        '😲 Whoa! That was unexpected! So cool! 😲',
        '🤯 Wow! This is going to be really amazing! 🤯',
        '😍 Oh! I love this! So beautiful! 😍',
        '🎊 Fantastic! This is really magical! 🎊',
        '🌟 Omg! This is so cool! I\'m impressed! 🌟'
      ];

      final randomMessage = surpriseMessages[DateTime.now().millisecond % surpriseMessages.length];
      await _flutterTts!.speak(randomMessage);
    } catch (e) {
      print('Funny surprise error: $e');
    }
  }

  /// Set speech rate (0.5 to 2.0, default 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      // Clamp rate between 0.5 and 2.0
      final clampedRate = rate.clamp(0.5, 2.0);
      await _flutterTts!.setSpeechRate(clampedRate);
      print('✓ Speech rate set to $clampedRate');
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  /// Set pitch (0.5 to 2.0, default 1.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      // Clamp pitch between 0.5 and 2.0
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts!.setPitch(clampedPitch);
      print('✓ Pitch set to $clampedPitch');
    } catch (e) {
      print('Error setting pitch: $e');
    }
  }

  /// Set volume (0.0 to 1.0, default 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts!.setVolume(clampedVolume);
      print('✓ Volume set to $clampedVolume');
    } catch (e) {
      print('Error setting volume: $e');
    }
  }
}
