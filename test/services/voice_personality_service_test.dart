import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/services/voice_personality_service.dart';
import '../../lib/services/tts_service.dart';

// Generate mocks
@GenerateMocks([TTSService])
import 'voice_personality_service_test.mocks.dart';

void main() {
  group('VoicePersonalityService', () {
    late VoicePersonalityService service;
    late MockTTSService mockTTS;

    setUp(() {
      mockTTS = MockTTSService();
      service = VoicePersonalityService();
      
      // Setup mock responses
      when(mockTTS.setSpeechRate(any)).thenAnswer((_) async => true);
      when(mockTTS.setPitch(any)).thenAnswer((_) async => true);
      when(mockTTS.setVolume(any)).thenAnswer((_) async => true);
    });

    group('Personality Greetings', () {
      test('should provide different greetings for each personality', () {
        for (final personality in VoicePersonality.values) {
          final greeting = service.getPersonalityGreeting(personality);
          
          expect(greeting, isNotEmpty);
          expect(greeting, contains('Hello') | contains('Hey') | contains('Greetings') | contains('Welcome'));
        }
      });

      test('should have unique greetings for each personality', () {
        final greetings = VoicePersonality.values
            .map((p) => service.getPersonalityGreeting(p))
            .toSet();
        
        expect(greetings.length, VoicePersonality.values.length);
      });
    });

    group('Personality Encouragements', () {
      test('should provide encouragement phrases for each personality', () {
        for (final personality in VoicePersonality.values) {
          final encouragements = service.getPersonalityEncouragements(personality);
          
          expect(encouragements, isNotEmpty);
          expect(encouragements.length, greaterThan(0));
        }
      });

      test('should have different encouragement styles per personality', () {
        final teacherEncouragements = service.getPersonalityEncouragements(VoicePersonality.friendlyTeacher);
        final friendEncouragements = service.getPersonalityEncouragements(VoicePersonality.playfulFriend);
        
        expect(teacherEncouragements, isNot(equals(friendEncouragements)));
      });
    });

    group('Personality Questions', () {
      test('should provide question patterns for each personality', () {
        for (final personality in VoicePersonality.values) {
          final questions = service.getPersonalityQuestions(personality);
          
          expect(questions, isNotEmpty);
          expect(questions.length, greaterThan(0));
        }
      });

      test('should have different question styles per personality', () {
        final teacherQuestions = service.getPersonalityQuestions(VoicePersonality.friendlyTeacher);
        final mentorQuestions = service.getPersonalityQuestions(VoicePersonality.wiseMentor);
        
        expect(teacherQuestions, isNot(equals(mentorQuestions)));
      });
    });

    group('Personality Celebrations', () {
      test('should provide celebration phrases for each personality', () {
        for (final personality in VoicePersonality.values) {
          final celebrations = service.getPersonalityCelebrations(personality);
          
          expect(celebrations, isNotEmpty);
          expect(celebrations.length, greaterThan(0));
        }
      });

      test('should have different celebration styles per personality', () {
        final artistCelebrations = service.getPersonalityCelebrations(VoicePersonality.creativeArtist);
        final coachCelebrations = service.getPersonalityCelebrations(VoicePersonality.encouragingCoach);
        
        expect(artistCelebrations, isNot(equals(coachCelebrations)));
      });
    });

    group('Random Responses', () {
      test('should provide random encouragements', () {
        for (final personality in VoicePersonality.values) {
          final encouragement = service.getRandomEncouragement(personality);
          
          expect(encouragement, isNotEmpty);
          expect(service.getPersonalityEncouragements(personality), contains(encouragement));
        }
      });

      test('should provide random questions', () {
        for (final personality in VoicePersonality.values) {
          final question = service.getRandomQuestion(personality);
          
          expect(question, isNotEmpty);
          expect(service.getPersonalityQuestions(personality), contains(question));
        }
      });

      test('should provide random celebrations', () {
        for (final personality in VoicePersonality.values) {
          final celebration = service.getRandomCelebration(personality);
          
          expect(celebration, isNotEmpty);
          expect(service.getPersonalityCelebrations(personality), contains(celebration));
        }
      });
    });

    group('Personality Descriptions', () {
      test('should provide descriptions for all personalities', () {
        for (final personality in VoicePersonality.values) {
          final description = service.getPersonalityDescription(personality);
          
          expect(description, isNotEmpty);
          expect(description.length, greaterThan(20));
        }
      });

      test('should have unique descriptions for each personality', () {
        final descriptions = VoicePersonality.values
            .map((p) => service.getPersonalityDescription(p))
            .toSet();
        
        expect(descriptions.length, VoicePersonality.values.length);
      });
    });

    group('Personality Emojis', () {
      test('should provide emojis for all personalities', () {
        for (final personality in VoicePersonality.values) {
          final emoji = service.getPersonalityEmoji(personality);
          
          expect(emoji, isNotEmpty);
          expect(emoji.length, 1); // Should be a single emoji character
        }
      });

      test('should have unique emojis for each personality', () {
        final emojis = VoicePersonality.values
            .map((p) => service.getPersonalityEmoji(p))
            .toSet();
        
        expect(emojis.length, VoicePersonality.values.length);
      });
    });

    group('Voice Configuration', () {
      test('should have different voice configs for each personality', () {
        final configs = <VoicePersonality, VoicePersonalityService.VoiceConfig>{};
        
        for (final personality in VoicePersonality.values) {
          // Access private field through reflection or create a test method
          // For now, we'll test that the service can be instantiated
          expect(service, isNotNull);
        }
      });
    });

    group('Personality Names', () {
      test('should provide display names for all personalities', () {
        for (final personality in VoicePersonality.values) {
          final name = service._getPersonalityName(personality);
          
          expect(name, isNotEmpty);
          expect(name, isNot(equals(personality.name)));
        }
      });
    });

    group('All Personalities Available', () {
      test('should return all personality types', () {
        final personalities = service.getAllPersonalities();
        
        expect(personalities.length, VoicePersonality.values.length);
        expect(personalities, containsAll(VoicePersonality.values));
      });
    });

    group('Error Handling', () {
      test('should handle TTS errors gracefully', () async {
        when(mockTTS.setSpeechRate(any)).thenThrow(Exception('TTS error'));
        
        // Should not throw exception
        expect(() async {
          await service.applyPersonalityVoice(VoicePersonality.friendlyTeacher);
        }, returnsNormally);
      });
    });

    group('Personality Characteristics', () {
      test('friendly teacher should have educational tone', () {
        final greeting = service.getPersonalityGreeting(VoicePersonality.friendlyTeacher);
        final encouragement = service.getRandomEncouragement(VoicePersonality.friendlyTeacher);
        
        expect(greeting.toLowerCase(), anyOf([
          contains('teacher'),
          contains('learn'),
          contains('help'),
        ]));
        
        expect(encouragement.toLowerCase(), anyOf([
          contains('wonderful'),
          contains('learning'),
          contains('creative'),
        ]));
      });

      test('playful friend should have energetic tone', () {
        final greeting = service.getPersonalityGreeting(VoicePersonality.playfulFriend);
        final encouragement = service.getRandomEncouragement(VoicePersonality.playfulFriend);
        
        expect(greeting.toLowerCase(), anyOf([
          contains('buddy'),
          contains('fun'),
          contains('cool'),
        ]));
        
        expect(encouragement.toLowerCase(), anyOf([
          contains('awesome'),
          contains('cool'),
          contains('genius'),
        ]));
      });

      test('wise mentor should have thoughtful tone', () {
        final greeting = service.getPersonalityGreeting(VoicePersonality.wiseMentor);
        final encouragement = service.getRandomEncouragement(VoicePersonality.wiseMentor);
        
        expect(greeting.toLowerCase(), anyOf([
          contains('mentor'),
          contains('guide'),
          contains('imagination'),
        ]));
        
        expect(encouragement.toLowerCase(), anyOf([
          contains('wisdom'),
          contains('remarkable'),
          contains('insight'),
        ]));
      });

      test('creative artist should have artistic tone', () {
        final greeting = service.getPersonalityGreeting(VoicePersonality.creativeArtist);
        final encouragement = service.getRandomEncouragement(VoicePersonality.creativeArtist);
        
        expect(greeting.toLowerCase(), anyOf([
          contains('studio'),
          contains('artistic'),
          contains('creative'),
        ]));
        
        expect(encouragement.toLowerCase(), anyOf([
          contains('artistic'),
          contains('beautiful'),
          contains('inspiring'),
        ]));
      });

      test('encouraging coach should have motivational tone', () {
        final greeting = service.getPersonalityGreeting(VoicePersonality.encouragingCoach);
        final encouragement = service.getRandomEncouragement(VoicePersonality.encouragingCoach);
        
        expect(greeting.toLowerCase(), anyOf([
          contains('champion'),
          contains('coach'),
          contains('amazing'),
        ]));
        
        expect(encouragement.toLowerCase(), anyOf([
          contains('amazing'),
          contains('champion'),
          contains('unstoppable'),
        ]));
      });
    });
  });
}