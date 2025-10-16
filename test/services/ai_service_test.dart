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
      test('should parse rainbow cow with sparkles correctly', () {
        final result = aiService.parseCreatureRequest('I want a rainbow cow with sparkles');

        expect(result['creatureType'], equals('cow'));
        expect(result['color'], equals('rainbow'));
        expect(result['effects'], contains('sparkles'));
        expect(result['size'], equals('normal'));
      });

      test('should parse pink pig correctly', () {
        final result = aiService.parseCreatureRequest('Make me a pink pig');

        expect(result['creatureType'], equals('pig'));
        expect(result['color'], equals('pink'));
        expect(result['size'], equals('normal'));
      });

      test('should parse blue chicken that flies', () {
        final result = aiService.parseCreatureRequest('I want a blue chicken that flies');

        expect(result['creatureType'], equals('chicken'));
        expect(result['color'], equals('blue'));
        expect(result['effects'], contains('flies'));
      });

      test('should parse tiny creatures', () {
        final result = aiService.parseCreatureRequest('A tiny cow');

        expect(result['size'], equals('tiny'));
      });

      test('should parse huge creatures', () {
        final result = aiService.parseCreatureRequest('A huge dragon');

        expect(result['size'], equals('big'));
        expect(result['creatureType'], equals('dragon'));
      });

      test('should parse multiple effects', () {
        final result = aiService.parseCreatureRequest('A cow with sparkles and glows and flies');

        expect(result['effects'], contains('sparkles'));
        expect(result['effects'], contains('glows'));
        expect(result['effects'], contains('flies'));
      });

      test('should parse dragon correctly', () {
        final result = aiService.parseCreatureRequest('I want a dragon');

        expect(result['creatureType'], equals('dragon'));
      });

      test('should parse unicorn correctly', () {
        final result = aiService.parseCreatureRequest('Make me a unicorn');

        expect(result['creatureType'], equals('unicorn'));
      });

      test('should parse phoenix correctly', () {
        final result = aiService.parseCreatureRequest('Create a phoenix with fire');

        expect(result['creatureType'], equals('phoenix'));
        expect(result['effects'], contains('fire'));
      });

      test('should handle case insensitive input', () {
        final result = aiService.parseCreatureRequest('I WANT A RAINBOW COW');

        expect(result['creatureType'], equals('cow'));
        expect(result['color'], equals('rainbow'));
      });

      test('should include timestamp', () {
        final result = aiService.parseCreatureRequest('A cow');

        expect(result['timestamp'], isNotNull);
        expect(result['timestamp'], isA<String>());
      });

      test('should calculate complexity', () {
        final result = aiService.parseCreatureRequest('A cow with sparkles that can fly and swim');

        expect(result['complexity'], isA<int>());
        expect(result['complexity'], greaterThan(1));
      });
    });

    group('validateCreatureRequest', () {
      test('should accept safe creature descriptions', () {
        for (final description in TestData.validCreatureDescriptions) {
          expect(aiService.validateCreatureRequest(description), isTrue,
              reason: 'Should accept: $description');
        }
      });

      test('should reject inappropriate content', () {
        for (final description in TestData.inappropriateInputs) {
          expect(aiService.validateCreatureRequest(description), isFalse,
              reason: 'Should reject: $description');
        }
      });

      test('should reject scary words', () {
        expect(aiService.validateCreatureRequest('A scary monster'), isFalse);
        expect(aiService.validateCreatureRequest('A frightening creature'), isFalse);
        expect(aiService.validateCreatureRequest('A terrifying dragon'), isFalse);
      });

      test('should reject violence words', () {
        expect(aiService.validateCreatureRequest('A creature that kills'), isFalse);
        expect(aiService.validateCreatureRequest('Something with blood'), isFalse);
        expect(aiService.validateCreatureRequest('A violent animal'), isFalse);
      });
    });

    group('validateContentForAge', () {
      test('should validate age 4-6 content correctly', () {
        expect(aiService.validateContentForAge('A pink cow', 5), isTrue);
        expect(aiService.validateContentForAge('A sparkly unicorn', 6), isTrue);
        expect(aiService.validateContentForAge('A sword', 5), isFalse);
        expect(aiService.validateContentForAge('Fire dragon', 6), isFalse);
      });

      test('should validate age 7-8 content correctly', () {
        expect(aiService.validateContentForAge('A dragon with fire', 8), isTrue);
        expect(aiService.validateContentForAge('A magical sword', 7), isTrue);
        expect(aiService.validateContentForAge('A scary creature', 8), isFalse);
        expect(aiService.validateContentForAge('A dark monster', 7), isFalse);
      });

      test('should validate age 9-10 content correctly', () {
        expect(aiService.validateContentForAge('A powerful dragon', 10), isTrue);
        expect(aiService.validateContentForAge('A shadow creature', 9), isTrue);
        expect(aiService.validateContentForAge('Death and destruction', 10), isFalse);
        expect(aiService.validateContentForAge('Evil demon', 9), isFalse);
      });

      test('should be more restrictive for younger ages', () {
        const content = 'A sword with fire';

        expect(aiService.validateContentForAge(content, 5), isFalse);
        expect(aiService.validateContentForAge(content, 8), isTrue);
        expect(aiService.validateContentForAge(content, 10), isTrue);
      });
    });

    group('getCreatureSuggestions', () {
      test('should return age-appropriate suggestions for age 5', () {
        final suggestions = aiService.getCreatureSuggestions(5);

        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThan(0));
        expect(suggestions.every((s) => s.isNotEmpty), isTrue);
      });

      test('should return more complex suggestions for age 8', () {
        final suggestions = aiService.getCreatureSuggestions(8);

        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.contains('dragon') || s.contains('unicorn')), isTrue);
      });

      test('should return most complex suggestions for age 10', () {
        final suggestions = aiService.getCreatureSuggestions(10);

        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.contains('massive') || s.contains('lightning')), isTrue);
      });

      test('should return different suggestions for different ages', () {
        final suggestions5 = aiService.getCreatureSuggestions(5);
        final suggestions10 = aiService.getCreatureSuggestions(10);

        expect(suggestions5, isNot(equals(suggestions10)));
      });
    });

    group('getAgeAppropriateSuggestions', () {
      test('should return safe suggestions for age 4-6', () {
        final suggestions = aiService.getAgeAppropriateSuggestions(5);

        expect(suggestions, isNotEmpty);
        expect(suggestions.every((s) => !s.contains('sword')), isTrue);
        expect(suggestions.every((s) => !s.contains('weapon')), isTrue);
      });

      test('should include more variety for age 7-8', () {
        final suggestions = aiService.getAgeAppropriateSuggestions(8);

        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThanOrEqualTo(5));
      });

      test('should include advanced content for age 9-10', () {
        final suggestions = aiService.getAgeAppropriateSuggestions(10);

        expect(suggestions, isNotEmpty);
        expect(suggestions.any((s) => s.contains('massive') || s.contains('dragon')), isTrue);
      });
    });

    group('getEncouragingResponse', () {
      test('should return encouraging message', () {
        final response = aiService.getEncouragingResponse();

        expect(response, isNotEmpty);
        expect(response, isA<String>());
      });

      test('should return positive words', () {
        final response = aiService.getEncouragingResponse();

        final positiveWords = ['amazing', 'cool', 'love', 'fantastic', 'brilliant', 'awesome', 'excellent', 'wonderful'];
        expect(positiveWords.any((word) => response.toLowerCase().contains(word)), isTrue);
      });

      test('should not be empty', () {
        final response = aiService.getEncouragingResponse();

        expect(response.trim(), isNotEmpty);
      });
    });

    group('isConfigured', () {
      test('should check if API key is configured', () {
        // Note: This will depend on .env file being present
        final isConfigured = aiService.isConfigured;

        expect(isConfigured, isA<bool>());
      });
    });

    group('edge cases', () {
      test('should handle empty input gracefully', () {
        final result = aiService.parseCreatureRequest('');

        expect(result, isNotNull);
        expect(result['creatureType'], isNotNull);
      });

      test('should handle very long input', () {
        final longInput = 'I want a ' + 'rainbow ' * 100 + 'cow';
        final result = aiService.parseCreatureRequest(longInput);

        expect(result, isNotNull);
        expect(result['creatureType'], equals('cow'));
        expect(result['color'], equals('rainbow'));
      });

      test('should handle special characters', () {
        final result = aiService.parseCreatureRequest('I want a @#\$% cow!!!');

        expect(result, isNotNull);
        expect(result['creatureType'], equals('cow'));
      });

      test('should handle numbers', () {
        final result = aiService.parseCreatureRequest('123 cow 456');

        expect(result, isNotNull);
        expect(result['creatureType'], equals('cow'));
      });
    });
  });
}
