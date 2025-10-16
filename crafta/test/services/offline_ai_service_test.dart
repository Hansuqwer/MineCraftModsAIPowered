import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/services/offline_ai_service.dart';

void main() {
  group('OfflineAIService Tests', () {
    late OfflineAIService offlineService;

    setUp(() {
      offlineService = OfflineAIService();
    });

    test('should return response for known creature', () {
      final response = offlineService.getOfflineResponse('rainbow cow');

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('cow'));
    });

    test('should return response for pink pig', () {
      final response = offlineService.getOfflineResponse('pink pig');

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('pig'));
    });

    test('should return response for blue chicken', () {
      final response = offlineService.getOfflineResponse('blue chicken');

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('chicken'));
    });

    test('should return response for dragon', () {
      final response = offlineService.getOfflineResponse('dragon');

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('dragon'));
    });

    test('should return response for unicorn', () {
      final response = offlineService.getOfflineResponse('unicorn');

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('unicorn'));
    });

    test('should return age-appropriate suggestion for unknown input', () {
      final response = offlineService.getOfflineResponse('something unknown', age: 6);

      expect(response, isNotEmpty);
      expect(response, contains('offline'));
    });

    test('should have offline response for common creatures', () {
      expect(offlineService.hasOfflineResponse('rainbow cow'), isTrue);
      expect(offlineService.hasOfflineResponse('pink pig'), isTrue);
      expect(offlineService.hasOfflineResponse('blue chicken'), isTrue);
    });

    test('should return false for uncommon creatures', () {
      expect(offlineService.hasOfflineResponse('purple elephant'), isFalse);
    });

    test('should return encouraging message', () {
      final encouragement = offlineService.getOfflineEncouragement();

      expect(encouragement, isNotEmpty);
      expect(encouragement.length, greaterThan(10));
    });

    test('should return help message', () {
      final help = offlineService.getOfflineHelpMessage();

      expect(help, isNotEmpty);
      expect(help, contains('offline'));
      expect(help, contains('create'));
    });

    test('should cache custom responses', () {
      offlineService.cacheResponse('custom creature', 'Custom response!');

      final response = offlineService.getOfflineResponse('custom creature');
      expect(response, equals('Custom response!'));
    });

    test('should get cache statistics', () {
      final stats = offlineService.getCacheStats();

      expect(stats, isNotEmpty);
      expect(stats['total_responses'], greaterThan(0));
      expect(stats['default_responses'], greaterThan(0));
    });

    test('should handle case insensitive input', () {
      final response1 = offlineService.getOfflineResponse('RAINBOW COW');
      final response2 = offlineService.getOfflineResponse('rainbow cow');

      expect(response1, isNotEmpty);
      expect(response2, isNotEmpty);
    });

    test('should handle punctuation in input', () {
      final response = offlineService.getOfflineResponse('rainbow cow!!!');

      expect(response, isNotEmpty);
    });

    test('should provide different suggestions for different ages', () {
      final response5 = offlineService.getOfflineResponse('unknown', age: 5);
      final response10 = offlineService.getOfflineResponse('unknown', age: 10);

      expect(response5, isNotEmpty);
      expect(response10, isNotEmpty);
    });

    test('should clear custom cache', () {
      offlineService.cacheResponse('test', 'test response');
      offlineService.clearCustomCache();

      final stats = offlineService.getCacheStats();
      expect(stats['custom_responses'], equals(0));
    });

    test('should return non-empty responses for all common creatures', () {
      final creatures = [
        'cow',
        'pig',
        'chicken',
        'dragon',
        'unicorn',
        'rainbow cow',
        'pink pig',
        'blue chicken',
      ];

      for (final creature in creatures) {
        final response = offlineService.getOfflineResponse(creature);
        expect(response, isNotEmpty, reason: 'Response for $creature should not be empty');
      }
    });
  });
}
