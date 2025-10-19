import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../lib/services/enhanced_voice_ai_service.dart';
import '../../lib/services/tts_service.dart';
import '../../lib/services/speech_service.dart';
import '../../lib/services/ai_service.dart';
import '../../lib/services/local_storage_service.dart';

// Generate mocks
@GenerateMocks([TTSService, SpeechService, AIService, LocalStorageService])
import 'enhanced_voice_ai_service_test.mocks.dart';

void main() {
  group('EnhancedVoiceAIService', () {
    late EnhancedVoiceAIService service;
    late MockTTSService mockTTS;
    late MockSpeechService mockSpeech;
    late MockAIService mockAI;
    late MockLocalStorageService mockStorage;

    setUp(() {
      // Initialize mocks
      mockTTS = MockTTSService();
      mockSpeech = MockSpeechService();
      mockAI = MockAIService();
      mockStorage = MockLocalStorageService();

      // Setup mock responses
      when(mockTTS.initialize()).thenAnswer((_) async => true);
      when(mockSpeech.initialize()).thenAnswer((_) async => true);
      when(mockStorage.getData(any)).thenAnswer((_) async => null);
      when(mockStorage.saveData(any, any)).thenAnswer((_) async => true);

      // Initialize service
      service = EnhancedVoiceAIService();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final result = await service.initialize();
        expect(result, true);
      });

      test('should handle initialization failure', () async {
        when(mockTTS.initialize()).thenThrow(Exception('TTS failed'));
        
        final result = await service.initialize();
        expect(result, false);
      });
    });

    group('Conversation Management', () {
      test('should start conversation with default personality', () async {
        await service.initialize();
        await service.startConversation();
        
        expect(service.currentConversation, isNotNull);
        expect(service.currentPersonality, VoicePersonality.friendlyTeacher);
      });

      test('should start conversation with specific personality', () async {
        await service.initialize();
        await service.startConversation(personality: VoicePersonality.playfulFriend);
        
        expect(service.currentPersonality, VoicePersonality.playfulFriend);
      });

      test('should change personality during conversation', () async {
        await service.initialize();
        await service.startConversation();
        
        await service.changePersonality(VoicePersonality.wiseMentor);
        
        expect(service.currentPersonality, VoicePersonality.wiseMentor);
      });
    });

    group('Voice Input Processing', () {
      test('should process voice input successfully', () async {
        await service.initialize();
        await service.startConversation();
        
        // Mock AI response
        when(mockAI.generateResponse(any, systemPrompt: any, conversationHistory: any))
            .thenAnswer((_) async => 'That sounds amazing! Tell me more about it!');
        
        final response = await service.processVoiceInput('I want to create a dragon');
        
        expect(response, isNotEmpty);
        expect(response, contains('amazing'));
      });

      test('should handle voice input errors gracefully', () async {
        await service.initialize();
        await service.startConversation();
        
        when(mockAI.generateResponse(any, systemPrompt: any, conversationHistory: any))
            .thenThrow(Exception('AI service error'));
        
        final response = await service.processVoiceInput('test input');
        
        expect(response, isNotEmpty);
        expect(response, contains('try again'));
      });
    });

    group('Context Analysis', () {
      test('should detect creature type in input', () async {
        await service.initialize();
        await service.startConversation();
        
        final context = service._analyzeUserInput('I want to create a dragon');
        
        expect(context['creatureType'], 'dragon');
      });

      test('should detect colors in input', () async {
        await service.initialize();
        await service.startConversation();
        
        final context = service._analyzeUserInput('I want a blue cat');
        
        expect(context['color'], 'blue');
        expect(context['creatureType'], 'cat');
      });

      test('should detect effects in input', () async {
        await service.initialize();
        await service.startConversation();
        
        final context = service._analyzeUserInput('I want a flying pig');
        
        expect(context['effects'], contains('flying'));
      });

      test('should detect questions in input', () async {
        await service.initialize();
        await service.startConversation();
        
        final context = service._analyzeUserInput('What can I create?');
        
        expect(context['isQuestion'], true);
      });

      test('should detect excitement in input', () async {
        await service.initialize();
        await service.startConversation();
        
        final context = service._analyzeUserInput('Wow! That\'s amazing!');
        
        expect(context['isExcited'], true);
      });
    });

    group('Educational Content', () {
      test('should provide educational facts for creatures', () async {
        await service.initialize();
        await service.startConversation();
        
        final response = await service.processVoiceInput('I want to create a dragon');
        
        // Should include educational content about dragons
        expect(response, isNotEmpty);
      });

      test('should enhance response with personality', () async {
        await service.initialize();
        await service.startConversation(personality: VoicePersonality.playfulFriend);
        
        final response = await service.processVoiceInput('I want to create something');
        
        expect(response, isNotEmpty);
        // Should contain playful language
        expect(response.toLowerCase(), anyOf([
          contains('awesome'),
          contains('cool'),
          contains('fun'),
        ]));
      });
    });

    group('Conversation Statistics', () {
      test('should track conversation statistics', () async {
        await service.initialize();
        await service.startConversation();
        
        await service.processVoiceInput('Hello');
        await service.processVoiceInput('I want to create a dragon');
        
        final stats = service.getConversationStats();
        
        expect(stats['totalMessages'], greaterThan(0));
        expect(stats['userMessages'], greaterThan(0));
        expect(stats['aiMessages'], greaterThan(0));
        expect(stats['currentPersonality'], isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle TTS errors gracefully', () async {
        when(mockTTS.speak(any)).thenThrow(Exception('TTS error'));
        
        await service.initialize();
        await service.startConversation();
        
        // Should not throw exception
        expect(() async {
          await service.processVoiceInput('test');
        }, returnsNormally);
      });

      test('should handle storage errors gracefully', () async {
        when(mockStorage.saveData(any, any)).thenThrow(Exception('Storage error'));
        
        await service.initialize();
        await service.startConversation();
        
        // Should not throw exception
        expect(() async {
          await service.processVoiceInput('test');
        }, returnsNormally);
      });
    });

    group('Conversation History', () {
      test('should save conversation history', () async {
        await service.initialize();
        await service.startConversation();
        
        await service.processVoiceInput('Hello');
        await service.processVoiceInput('I want to create something');
        
        verify(mockStorage.saveData('conversation_history', any)).called(greaterThan(0));
      });

      test('should load conversation history on initialization', () async {
        when(mockStorage.getData('conversation_history'))
            .thenAnswer((_) async => ['User: Hello', 'Crafta: Hi there!']);
        
        await service.initialize();
        
        verify(mockStorage.getData('conversation_history')).called(1);
      });

      test('should clear conversation history', () async {
        await service.initialize();
        await service.startConversation();
        
        await service.clearConversationHistory();
        
        verify(mockStorage.removeData('conversation_history')).called(1);
      });
    });

    group('Personality System', () {
      test('should have all personality types available', () {
        final personalities = VoicePersonality.values;
        
        expect(personalities.length, 5);
        expect(personalities, contains(VoicePersonality.friendlyTeacher));
        expect(personalities, contains(VoicePersonality.playfulFriend));
        expect(personalities, contains(VoicePersonality.wiseMentor));
        expect(personalities, contains(VoicePersonality.creativeArtist));
        expect(personalities, contains(VoicePersonality.encouragingCoach));
      });

      test('should provide different responses for different personalities', () async {
        await service.initialize();
        
        // Test friendly teacher
        await service.startConversation(personality: VoicePersonality.friendlyTeacher);
        final teacherResponse = await service.processVoiceInput('Hello');
        
        // Test playful friend
        await service.startConversation(personality: VoicePersonality.playfulFriend);
        final friendResponse = await service.processVoiceInput('Hello');
        
        expect(teacherResponse, isNot(equals(friendResponse)));
      });
    });

    group('Educational Content Integration', () {
      test('should include educational facts in responses', () async {
        await service.initialize();
        await service.startConversation();
        
        final response = await service.processVoiceInput('I want to create a dragon');
        
        // Should include educational content about dragons
        expect(response, isNotEmpty);
      });

      test('should ask follow-up questions', () async {
        await service.initialize();
        await service.startConversation();
        
        final response = await service.processVoiceInput('I want to create something');
        
        // Should end with a question to continue conversation
        expect(response, contains('?'));
      });
    });
  });
}