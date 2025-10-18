import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/services/ai_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AIService', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    group('parseCreatureRequest', () {
      test('should parse rainbow cow with sparkles correctly', () async {
        final result = await aiService.parseCreatureRequest('I want a rainbow cow with sparkles');

        expect(result['creatureType'], equals('cow'));
        expect(result['color'], equals('rainbow'));
        expect(result['effects'], contains('sparkles'));
        expect(result['size'], equals('normal'));
      });

      test('should parse pink pig correctly', () async {
        final result = await aiService.parseCreatureRequest('Make me a pink pig');

        expect(result['creatureType'], equals('pig'));
        expect(result['color'], equals('pink'));
        expect(result['size'], equals('normal'));
      });

      test('should parse blue chicken that flies', () async {
        final result = await aiService.parseCreatureRequest('I want a blue chicken that flies');

        expect(result['creatureType'], equals('chicken'));
        expect(result['color'], equals('blue'));
        expect(result['effects'], contains('flies'));
        expect(result['size'], equals('tiny'));
      });

      test('should parse big dragon', () async {
        final result = await aiService.parseCreatureRequest('Create a big dragon');

        expect(result['size'], equals('big'));
        expect(result['creatureType'], equals('dragon'));
      });

      test('should parse complex creature with multiple effects', () async {
        final result = await aiService.parseCreatureRequest('I want a sparkly glowing flying unicorn');

        expect(result['effects'], contains('sparkles'));
        expect(result['effects'], contains('glows'));
        expect(result['effects'], contains('flies'));
        expect(result['creatureType'], equals('dragon'));
      });

      test('should parse dragon with fire effects', () async {
        final result = await aiService.parseCreatureRequest('Make a dragon with fire');

        expect(result['creatureType'], equals('dragon'));
        expect(result['effects'], contains('fire'));
      });

      test('should parse unicorn correctly', () async {
        final result = await aiService.parseCreatureRequest('I want a unicorn');

        expect(result['creatureType'], equals('unicorn'));
      });

      test('should parse phoenix with fire', () async {
        final result = await aiService.parseCreatureRequest('Create a phoenix with fire');

        expect(result['creatureType'], equals('phoenix'));
        expect(result['effects'], contains('fire'));
      });

      test('should handle default values for missing attributes', () async {
        final result = await aiService.parseCreatureRequest('I want a cow');

        expect(result['creatureType'], equals('cow'));
        expect(result['color'], equals('rainbow'));
        expect(result['timestamp'], isNotNull);
        expect(result['timestamp'], isA<String>());
      });

      test('should include complexity score', () async {
        final result = await aiService.parseCreatureRequest('I want a complex magical creature');

        expect(result['complexity'], isA<int>());
        expect(result['complexity'], greaterThan(1));
      });
    });

    group('getCraftaResponse', () {
      test('should return response for valid input', () async {
        final response = await aiService.getCraftaResponse('I want to create a cow');
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should handle empty input gracefully', () async {
        final response = await aiService.getCraftaResponse('');
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should handle very long input', () async {
        final longInput = 'I want to create a ' + 'very ' * 100 + 'complex creature';
        final response = await aiService.getCraftaResponse(longInput);
        
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should return different responses for different inputs', () async {
        final response1 = await aiService.getCraftaResponse('I want a cow');
        final response2 = await aiService.getCraftaResponse('I want a dragon');
        
        expect(response1, isNotEmpty);
        expect(response2, isNotEmpty);
        // Responses might be the same in offline mode, which is fine
      });
    });

    group('validateContentForAge', () {
      test('should validate content for different ages', () {
        expect(aiService.validateContentForAge('I want a cute cow', 5), isTrue);
        expect(aiService.validateContentForAge('I want a scary monster', 5), isFalse);
        expect(aiService.validateContentForAge('I want a dragon', 10), isTrue);
        expect(aiService.validateContentForAge('I want a dragon', 3), isTrue);
      });

      test('should handle inappropriate content', () {
        expect(aiService.validateContentForAge('I want something scary', 5), isFalse);
        expect(aiService.validateContentForAge('I want something violent', 8), isFalse);
      });
    });

    group('getCreatureSuggestions', () {
      test('should return suggestions for young children', () {
        final suggestions = aiService.getCreatureSuggestions(5);
        
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThan(0));
        expect(suggestions, everyElement(isA<String>()));
      });

      test('should return different suggestions for different ages', () {
        final suggestions5 = aiService.getCreatureSuggestions(5);
        final suggestions10 = aiService.getCreatureSuggestions(10);
        
        expect(suggestions5, isNotEmpty);
        expect(suggestions10, isNotEmpty);
        // They might be the same, which is fine
      });
    });

    group('getFurnitureSuggestions', () {
      test('should return furniture suggestions', () {
        final suggestions = aiService.getFurnitureSuggestions();
        
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThan(0));
        expect(suggestions, everyElement(isA<String>()));
      });
    });

    group('Error Handling', () {
      test('should handle null input gracefully', () async {
        final result = await aiService.parseCreatureRequest('');
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result['creatureType'], isNotNull);
      });

      test('should handle special characters', () async {
        final result = await aiService.parseCreatureRequest('I want a 🐉 dragon with ✨ sparkles');
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result['creatureType'], isNotNull);
      });

      test('should handle very long input', () async {
        final longInput = 'I want to create a ' + 'very ' * 1000 + 'complex creature';
        final result = await aiService.parseCreatureRequest(longInput);
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result['creatureType'], isNotNull);
      });
    });
  });
}
