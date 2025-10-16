import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/services/speech_service.dart';
import 'dart:io';

void main() {
  group('SpeechService Tests', () {
    late SpeechService speechService;

    setUp(() {
      speechService = SpeechService();
    });

    test('should initialize speech service', () async {
      // Test initialization
      final result = await speechService.initialize();
      
      // On desktop platforms, should return false
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        expect(result, false);
        expect(speechService.isAvailable, false);
      }
    });

    test('should handle platform detection correctly', () async {
      await speechService.initialize();
      
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        expect(speechService.isAvailable, false);
      }
    });

    test('should provide correct getters', () {
      expect(speechService.isListening, false);
      expect(speechService.isAvailable, false);
      expect(speechService.lastWords, '');
    });

    test('should handle startListening on desktop platforms', () async {
      await speechService.initialize();
      
      bool errorCalled = false;
      String errorMessage = '';
      
      await speechService.startListening(
        onResult: (text) {
          // Should not be called on desktop
          fail('onResult should not be called on desktop platforms');
        },
        onError: (error) {
          errorCalled = true;
          errorMessage = error;
        },
      );
      
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        expect(errorCalled, true);
        expect(errorMessage, 'Speech recognition not available');
      }
    });

    test('should handle stopListening gracefully', () async {
      await speechService.stopListening();
      expect(speechService.isListening, false);
    });

    test('should handle cancelListening gracefully', () async {
      await speechService.cancelListening();
      expect(speechService.isListening, false);
    });
  });

  group('SpeechService Integration Tests', () {
    test('should work with mock speech input', () async {
      final speechService = SpeechService();
      await speechService.initialize();
      
      // Simulate mock speech input
      const mockText = 'I want to create a rainbow cow with sparkles';
      
      // Test that we can handle the mock scenario
      expect(speechService.isAvailable, false); // Desktop platforms
      
      // Test error handling for desktop
      bool errorCalled = false;
      await speechService.startListening(
        onResult: (text) {
          fail('Should not reach onResult on desktop');
        },
        onError: (error) {
          errorCalled = true;
          expect(error, 'Speech recognition not available');
        },
      );
      
      expect(errorCalled, true);
    });
  });

  group('SpeechService Error Handling', () {
    test('should handle initialization errors gracefully', () async {
      final speechService = SpeechService();
      
      // Test that initialization doesn't throw
      expect(() async => await speechService.initialize(), returnsNormally);
    });

    test('should handle listening errors gracefully', () async {
      final speechService = SpeechService();
      await speechService.initialize();
      
      bool errorCalled = false;
      String errorMessage = '';
      
      await speechService.startListening(
        onResult: (text) {
          fail('Should not reach onResult');
        },
        onError: (error) {
          errorCalled = true;
          errorMessage = error;
        },
      );
      
      expect(errorCalled, true);
      expect(errorMessage, isNotEmpty);
    });
  });
}

