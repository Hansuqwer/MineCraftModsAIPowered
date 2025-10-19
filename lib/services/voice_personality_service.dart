import 'enhanced_voice_ai_service.dart';
import 'tts_service.dart';

/// Voice configuration for each personality
class VoiceConfig {
  final double speechRate;
  final double pitch;
  final double volume;
  final String emphasis;
  final double pauseLength;

  VoiceConfig({
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.emphasis,
    required this.pauseLength,
  });
}

/// Service for managing voice personality characteristics and TTS settings
class VoicePersonalityService {
  static final VoicePersonalityService _instance = VoicePersonalityService._internal();
  factory VoicePersonalityService() => _instance;
  VoicePersonalityService._internal();

  final TTSService _ttsService = TTSService();
  final EnhancedVoiceAIService _voiceAI = EnhancedVoiceAIService();

  // Personality-specific TTS configurations
  final Map<VoicePersonality, VoiceConfig> _personalityConfigs = {
    VoicePersonality.friendlyTeacher: VoiceConfig(
      speechRate: 0.5,    // Slower, more patient
      pitch: 1.1,         // Slightly higher for warmth
      volume: 0.9,        // Clear but not loud
      emphasis: 'gentle', // Gentle emphasis
      pauseLength: 0.8,   // Longer pauses for teaching
    ),
    VoicePersonality.playfulFriend: VoiceConfig(
      speechRate: 0.7,    // Faster, more energetic
      pitch: 1.3,         // Higher pitch for excitement
      volume: 0.95,       // Louder for enthusiasm
      emphasis: 'bouncy', // Bouncy, playful emphasis
      pauseLength: 0.4,   // Shorter pauses for energy
    ),
    VoicePersonality.wiseMentor: VoiceConfig(
      speechRate: 0.4,    // Slower, more thoughtful
      pitch: 0.9,         // Lower pitch for wisdom
      volume: 0.85,       // Softer, more contemplative
      emphasis: 'calm',   // Calm, measured emphasis
      pauseLength: 1.2,   // Longer pauses for reflection
    ),
    VoicePersonality.creativeArtist: VoiceConfig(
      speechRate: 0.6,    // Medium pace for creativity
      pitch: 1.2,         // Higher pitch for inspiration
      volume: 0.9,        // Clear and expressive
      emphasis: 'expressive', // Expressive, artistic emphasis
      pauseLength: 0.6,   // Medium pauses for thought
    ),
    VoicePersonality.encouragingCoach: VoiceConfig(
      speechRate: 0.8,    // Faster for motivation
      pitch: 1.0,         // Normal pitch for confidence
      volume: 0.95,       // Strong, confident volume
      emphasis: 'energetic', // Energetic, motivational emphasis
      pauseLength: 0.5,   // Short pauses for momentum
    ),
  };

  /// Apply personality-specific voice settings
  Future<void> applyPersonalityVoice(VoicePersonality personality) async {
    final config = _personalityConfigs[personality]!;
    
    try {
      // Apply TTS settings
      await _ttsService.setSpeechRate(config.speechRate);
      await _ttsService.setPitch(config.pitch);
      await _ttsService.setVolume(config.volume);
      
      // Store personality-specific settings
      await _storePersonalitySettings(personality, config);
      
      print('Applied voice settings for ${_getPersonalityName(personality)}');
    } catch (e) {
      print('Error applying personality voice settings: $e');
    }
  }

  /// Get personality-specific greeting
  String getPersonalityGreeting(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return 'Hello there! I\'m your friendly teacher, and I\'m so excited to help you learn and create today!';
      case VoicePersonality.playfulFriend:
        return 'Hey there, buddy! I\'m your playful friend, and we\'re going to have SO much fun together!';
      case VoicePersonality.wiseMentor:
        return 'Greetings, young creator. I am your wise mentor, here to guide your imagination to new heights.';
      case VoicePersonality.creativeArtist:
        return 'Welcome to our creative studio! I\'m your artistic companion, and together we\'ll paint with imagination!';
      case VoicePersonality.encouragingCoach:
        return 'Hey champion! I\'m your encouraging coach, and I believe you can create something absolutely amazing!';
    }
  }

  /// Get personality-specific encouragement phrases
  List<String> getPersonalityEncouragements(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return [
          'That\'s a wonderful idea! You\'re learning so much!',
          'I\'m so proud of your creativity!',
          'You\'re doing such a great job thinking this through!',
          'What a smart way to think about it!',
          'You\'re becoming such a creative thinker!'
        ];
      case VoicePersonality.playfulFriend:
        return [
          'Whoa, that\'s awesome! You\'re like a little genius!',
          'That\'s so cool! I love your imagination!',
          'You\'re the coolest kid ever!',
          'That idea is totally amazing!',
          'You\'re making this so much fun!'
        ];
      case VoicePersonality.wiseMentor:
        return [
          'Your creativity shows great wisdom and insight.',
          'You have a truly remarkable imagination.',
          'Your vision is both clear and inspired.',
          'You demonstrate the heart of a true creator.',
          'Your artistic soul shines brightly.'
        ];
      case VoicePersonality.creativeArtist:
        return [
          'Your artistic vision is absolutely inspiring!',
          'What a beautiful way to express your creativity!',
          'You\'re painting with the colors of imagination!',
          'Your creative spirit is truly magnificent!',
          'You\'re a natural-born artist!'
        ];
      case VoicePersonality.encouragingCoach:
        return [
          'You\'re doing amazing! Keep that creative energy flowing!',
          'Outstanding work! You\'re becoming a real champion!',
          'That\'s the spirit! You\'re unstoppable!',
          'You\'re crushing it! Keep going!',
          'Fantastic! You\'re a creative superstar!'
        ];
    }
  }

  /// Get personality-specific question patterns
  List<String> getPersonalityQuestions(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return [
          'Can you tell me more about what you\'d like to create?',
          'What do you think would make this even better?',
          'What colors would you like to use?',
          'How big should we make it?',
          'What special powers should it have?'
        ];
      case VoicePersonality.playfulFriend:
        return [
          'Ooh, tell me more! I\'m super curious!',
          'What else can we add to make it even cooler?',
          'Should we make it super big or tiny and cute?',
          'What if it could fly or swim or something awesome?',
          'Can you imagine what it would look like?'
        ];
      case VoicePersonality.wiseMentor:
        return [
          'What vision do you hold in your mind\'s eye?',
          'How shall we bring your imagination to life?',
          'What qualities would make this creation truly special?',
          'What story does this creature tell?',
          'How can we make it reflect your inner creativity?'
        ];
      case VoicePersonality.creativeArtist:
        return [
          'What colors and shapes dance in your imagination?',
          'How can we make this a true work of art?',
          'What artistic style speaks to your soul?',
          'What textures and patterns inspire you?',
          'How can we express your unique creative voice?'
        ];
      case VoicePersonality.encouragingCoach:
        return [
          'What amazing idea is brewing in that creative mind?',
          'How can we make this absolutely incredible?',
          'What would make you super proud of this creation?',
          'What\'s your vision for this masterpiece?',
          'How can we make this the best thing ever?'
        ];
    }
  }

  /// Get personality-specific celebration phrases
  List<String> getPersonalityCelebrations(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return [
          'Fantastic work! You\'re learning so much about creativity!',
          'I\'m so proud of what you\'ve created!',
          'You\'ve done such a wonderful job!',
          'This shows how much you\'ve learned!',
          'You\'re becoming such a creative thinker!'
        ];
      case VoicePersonality.playfulFriend:
        return [
          'Yay! That\'s going to be so much fun to play with!',
          'Whoa! This is going to be awesome!',
          'Cool! I can\'t wait to see it in action!',
          'Amazing! This is going to be the best!',
          'Awesome! You\'re the coolest!'
        ];
      case VoicePersonality.wiseMentor:
        return [
          'You have created something truly magnificent.',
          'Your creation reflects the depth of your imagination.',
          'This is a work of true artistic merit.',
          'You have brought something beautiful into the world.',
          'Your creative spirit has manifested something wonderful.'
        ];
      case VoicePersonality.creativeArtist:
        return [
          'This creation will be a true work of art!',
          'You\'ve painted something truly beautiful!',
          'Your artistic vision has come to life!',
          'This is a masterpiece of creativity!',
          'You\'re a true artist!'
        ];
      case VoicePersonality.encouragingCoach:
        return [
          'Outstanding! You\'re becoming a real creative champion!',
          'You\'re crushing it! This is going to be incredible!',
          'Fantastic! You\'re unstoppable!',
          'Amazing work! You\'re a creative superstar!',
          'You\'re doing incredible! Keep that momentum going!'
        ];
    }
  }

  /// Get random encouragement based on personality
  String getRandomEncouragement(VoicePersonality personality) {
    final encouragements = getPersonalityEncouragements(personality);
    final randomIndex = DateTime.now().millisecond % encouragements.length;
    return encouragements[randomIndex];
  }

  /// Get random question based on personality
  String getRandomQuestion(VoicePersonality personality) {
    final questions = getPersonalityQuestions(personality);
    final randomIndex = DateTime.now().millisecond % questions.length;
    return questions[randomIndex];
  }

  /// Get random celebration based on personality
  String getRandomCelebration(VoicePersonality personality) {
    final celebrations = getPersonalityCelebrations(personality);
    final randomIndex = DateTime.now().millisecond % celebrations.length;
    return celebrations[randomIndex];
  }

  /// Get personality display name
  String _getPersonalityName(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return 'Friendly Teacher';
      case VoicePersonality.playfulFriend:
        return 'Playful Friend';
      case VoicePersonality.wiseMentor:
        return 'Wise Mentor';
      case VoicePersonality.creativeArtist:
        return 'Creative Artist';
      case VoicePersonality.encouragingCoach:
        return 'Encouraging Coach';
    }
  }

  /// Store personality settings for persistence
  Future<void> _storePersonalitySettings(VoicePersonality personality, VoiceConfig config) async {
    // This could be extended to save to local storage
    // For now, we'll just log the settings
    print('Stored settings for ${_getPersonalityName(personality)}: ${config.toString()}');
  }

  /// Get all available personalities
  List<VoicePersonality> getAllPersonalities() {
    return VoicePersonality.values;
  }

  /// Get personality description
  String getPersonalityDescription(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return 'Patient, educational, and encouraging. Perfect for learning and exploration.';
      case VoicePersonality.playfulFriend:
        return 'Fun, energetic, and silly. Great for having a blast while creating!';
      case VoicePersonality.wiseMentor:
        return 'Thoughtful, guiding, and wise. Ideal for deep creative thinking.';
      case VoicePersonality.creativeArtist:
        return 'Imaginative, expressive, and artistic. Perfect for artistic exploration.';
      case VoicePersonality.encouragingCoach:
        return 'Motivational, supportive, and positive. Great for building confidence!';
    }
  }

  /// Get personality emoji
  String getPersonalityEmoji(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return '👩‍🏫';
      case VoicePersonality.playfulFriend:
        return '😄';
      case VoicePersonality.wiseMentor:
        return '🧙‍♂️';
      case VoicePersonality.creativeArtist:
        return '🎨';
      case VoicePersonality.encouragingCoach:
        return '🏆';
    }
  }
}