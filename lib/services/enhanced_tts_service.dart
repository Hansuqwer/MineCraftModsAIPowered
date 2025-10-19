import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced TTS service with speed controls and personality settings
class EnhancedTTSService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  TTSSettings _settings = TTSSettings.defaultSettings();

  /// Initialize TTS with enhanced settings
  Future<bool> initialize() async {
    // On desktop platforms, TTS may not be available
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print('TTS not available on desktop platforms');
      _isInitialized = false;
      return false;
    }

    _flutterTts = FlutterTts();

    try {
      // Load saved settings
      await _loadSettings();

      // Get current language from settings
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;

      // Set language based on current locale
      if (languageCode == 'sv') {
        await _flutterTts!.setLanguage('sv-SE'); // Swedish
      } else {
        await _flutterTts!.setLanguage('en-US'); // English (default)
      }

      // Apply settings
      await _applySettings();

      // Set voice characteristics for warmth
      if (Platform.isAndroid) {
        // Try to use a more natural voice on Android
        await _flutterTts!.setEngine('com.google.android.tts');
        await _flutterTts!.setLanguage(languageCode == 'sv' ? 'sv-SE' : 'en-US');
      }

      _isInitialized = true;
      print('Enhanced TTS initialized with settings: ${_settings.toString()}');
      return true;
    } catch (e) {
      print('TTS initialization error: $e');
      return false;
    }
  }

  /// Load TTS settings from storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _settings = TTSSettings(
        speed: TTSSpeed.values[prefs.getInt('tts_speed') ?? 1], // Normal by default
        pitch: prefs.getDouble('tts_pitch') ?? 1.2,
        volume: prefs.getDouble('tts_volume') ?? 0.9,
        personalityEnabled: prefs.getBool('tts_personality') ?? true,
        soundEffectsEnabled: prefs.getBool('tts_sound_effects') ?? true,
      );

      print('TTS settings loaded: ${_settings.toString()}');
    } catch (e) {
      print('Error loading TTS settings: $e');
      _settings = TTSSettings.defaultSettings();
    }
  }

  /// Save TTS settings to storage
  Future<void> saveSettings(TTSSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('tts_speed', settings.speed.index);
      await prefs.setDouble('tts_pitch', settings.pitch);
      await prefs.setDouble('tts_volume', settings.volume);
      await prefs.setBool('tts_personality', settings.personalityEnabled);
      await prefs.setBool('tts_sound_effects', settings.soundEffectsEnabled);

      _settings = settings;
      await _applySettings();

      print('TTS settings saved: ${settings.toString()}');
    } catch (e) {
      print('Error saving TTS settings: $e');
    }
  }

  /// Apply current settings to TTS engine
  Future<void> _applySettings() async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      // Apply speech rate based on speed setting
      double speechRate = _settings.speed.rate;
      await _flutterTts!.setSpeechRate(speechRate);

      // Apply pitch (higher for friendliness with kids)
      await _flutterTts!.setPitch(_settings.pitch);

      // Apply volume
      await _flutterTts!.setVolume(_settings.volume);

      print('TTS settings applied: rate=$speechRate, pitch=${_settings.pitch}, volume=${_settings.volume}');
    } catch (e) {
      print('Error applying TTS settings: $e');
    }
  }

  /// Speak the given text with personality
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('TTS not initialized');
      return;
    }

    try {
      // Add personality to the text if enabled
      final enhancedText = _settings.personalityEnabled
          ? await _addPersonalityToText(text)
          : text;

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
    return text;
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts!.stop();
    }
  }

  /// Check if TTS is available
  bool get isAvailable => _isInitialized;

  /// Get current settings
  TTSSettings get settings => _settings;

  /// Play celebration sound effect
  Future<void> playCelebrationSound() async {
    if (!_isInitialized || !_settings.soundEffectsEnabled) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;

      String sound = languageCode == 'sv' ? '🎉 Fantastiskt! Så bra gjort! 🎉' : '🎉 Amazing! Great job! 🎉';
      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Celebration sound error: $e');
    }
  }

  /// Play encouragement with personality
  Future<void> playEncouragement() async {
    if (!_isInitialized || !_settings.soundEffectsEnabled) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;

      final encouragementMessages = languageCode == 'sv' ? [
        '🎉 Fantastiskt jobbat! Du är så kreativ! 🎉',
        '🌟 Wow! Det där var verkligen imponerande! 🌟',
        '✨ Du har en sådan fantastisk fantasi! ✨',
        '🌈 Vilken cool idé! Du är verkligen en konstnär! 🌈',
        '🎨 Så bra! Du lär dig snabbt! 🎨',
      ] : [
        '🎉 Amazing job! You\'re so creative! 🎉',
        '🌟 Wow! That was really impressive! 🌟',
        '✨ You have such an amazing imagination! ✨',
        '🌈 What a cool idea! You\'re really an artist! 🌈',
        '🎨 So good! You learn so fast! 🎨',
      ];

      final randomMessage = encouragementMessages[DateTime.now().millisecond % encouragementMessages.length];
      await _flutterTts!.speak(randomMessage);
    } catch (e) {
      print('Encouragement error: $e');
    }
  }

  /// Play creature-specific sound
  Future<void> playCreatureSound(String creatureType) async {
    if (!_isInitialized || !_settings.soundEffectsEnabled) return;

    try {
      final currentLocale = await LanguageService.getCurrentLanguage();
      final languageCode = currentLocale.languageCode;
      final isSwedish = languageCode == 'sv';

      String sound = '';
      switch (creatureType.toLowerCase()) {
        case 'dragon':
        case 'drake':
          sound = isSwedish ? '🐉 Rååå! Jag är en vänlig drake! 🐉' : '🐉 Rawr! I\'m a friendly dragon! 🐉';
          break;
        case 'unicorn':
        case 'enhörning':
          sound = isSwedish ? '🦄 Gnägg! Jag är en magisk enhörning! 🦄' : '🦄 Neigh! I\'m a magical unicorn! 🦄';
          break;
        case 'cat':
        case 'katt':
          sound = isSwedish ? '🐱 Mjau! Jag är en magisk katt! 🐱' : '🐱 Meow! I\'m a magical cat! 🐱';
          break;
        case 'dog':
        case 'hund':
          sound = isSwedish ? '🐶 Voff! Jag är en magisk hund! 🐶' : '🐶 Woof! I\'m a magical dog! 🐶';
          break;
        default:
          sound = isSwedish ? '🌟 Hej! Jag är din magiska skapelse! 🌟' : '🌟 Hello! I\'m your magical creation! 🌟';
      }

      await _flutterTts!.speak(sound);
    } catch (e) {
      print('Creature sound error: $e');
    }
  }
}

/// TTS speed presets for kid-friendly interaction
enum TTSSpeed {
  slow,    // 0.4 - Very slow for younger kids or learning
  normal,  // 0.6 - Default comfortable speed
  fast,    // 0.8 - Faster for older kids

  ;

  double get rate {
    switch (this) {
      case TTSSpeed.slow:
        return 0.4;
      case TTSSpeed.normal:
        return 0.6;
      case TTSSpeed.fast:
        return 0.8;
    }
  }

  String get displayName {
    switch (this) {
      case TTSSpeed.slow:
        return 'Slow (Younger Kids)';
      case TTSSpeed.normal:
        return 'Normal';
      case TTSSpeed.fast:
        return 'Fast (Older Kids)';
    }
  }

  String get emoji {
    switch (this) {
      case TTSSpeed.slow:
        return '🐢';
      case TTSSpeed.normal:
        return '🐇';
      case TTSSpeed.fast:
        return '🚀';
    }
  }
}

/// TTS settings for enhanced voice control
class TTSSettings {
  final TTSSpeed speed;
  final double pitch;    // 0.5 to 2.0 (higher = more cheerful)
  final double volume;   // 0.0 to 1.0
  final bool personalityEnabled;
  final bool soundEffectsEnabled;

  TTSSettings({
    required this.speed,
    required this.pitch,
    required this.volume,
    required this.personalityEnabled,
    required this.soundEffectsEnabled,
  });

  factory TTSSettings.defaultSettings() {
    return TTSSettings(
      speed: TTSSpeed.normal,
      pitch: 1.2,  // Slightly higher for friendliness
      volume: 0.9,  // Slightly softer for warmth
      personalityEnabled: true,
      soundEffectsEnabled: true,
    );
  }

  TTSSettings copyWith({
    TTSSpeed? speed,
    double? pitch,
    double? volume,
    bool? personalityEnabled,
    bool? soundEffectsEnabled,
  }) {
    return TTSSettings(
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      personalityEnabled: personalityEnabled ?? this.personalityEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    );
  }

  @override
  String toString() {
    return 'TTSSettings(speed: ${speed.displayName}, pitch: $pitch, '
        'volume: $volume, personality: $personalityEnabled, '
        'soundEffects: $soundEffectsEnabled)';
  }
}
