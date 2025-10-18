import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'language_service.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    // On desktop platforms, speech recognition is not available
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print('Speech recognition not available on desktop platforms');
      _isAvailable = false;
      return false;
    }

    try {
      _isAvailable = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      print('Speech recognition initialized: $_isAvailable');
      return _isAvailable;
    } catch (e) {
      print('Speech initialization error: $e');
      _isAvailable = false;
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isAvailable) {
      onError('Speech recognition not available');
      return;
    }

    try {
      _isListening = true;
      print('Starting speech recognition...');
      
      // Get current language for speech recognition
      final currentLocale = await LanguageService.getCurrentLanguage();
      final localeId = currentLocale.languageCode == 'sv' ? 'sv_SE' : 'en_US';
      print('Using speech recognition locale: $localeId');
      
      await _speech.listen(
        onResult: (result) {
          print('Speech result: ${result.recognizedWords} (confidence: ${result.confidence})');
          _lastWords = result.recognizedWords;
          
          // Only process results with reasonable confidence
          if (result.confidence > 0.3) {
            if (result.finalResult) {
              print('Final result: $_lastWords (confidence: ${result.confidence})');
              onResult(_lastWords);
              _isListening = false;
            }
          } else {
            print('Low confidence result ignored: ${result.confidence}');
          }
        },
        listenFor: const Duration(seconds: 15), // Increased listening time
        pauseFor: const Duration(seconds: 2), // Reduced pause time
        partialResults: true,
        localeId: localeId,
        listenMode: ListenMode.confirmation, // Better for single commands
        cancelOnError: false, // Don't cancel on minor errors
      );
    } catch (e) {
      print('Speech listening error: $e');
      onError('Speech listening failed: $e');
      _isListening = false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      print('Speech recognition stopped');
    } catch (e) {
      print('Error stopping speech: $e');
    }
    _isListening = false;
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
      print('Speech recognition cancelled');
    } catch (e) {
      print('Error cancelling speech: $e');
    }
    _isListening = false;
  }
}
