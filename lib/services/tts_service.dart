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
      
      await _flutterTts!.setSpeechRate(0.5); // Much slower for kids
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.1); // Slightly higher pitch for friendly voice
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('TTS initialization error: $e');
      return false;
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('TTS not initialized');
      return;
    }

    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
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
}
