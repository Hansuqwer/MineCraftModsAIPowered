import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EncouragementManager {
  static final EncouragementManager _instance = EncouragementManager._internal();
  factory EncouragementManager() => _instance;
  EncouragementManager._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('EncouragementManager initialization failed: $e');
    }
  }

  Future<void> celebrate() async {
    if (!_isInitialized) {
      await init();
    }

    // Play encouraging TTS
    final encouragingPhrases = [
      "Amazing! Your dragon is ready!",
      "Wow! Look at that beautiful creature!",
      "Fantastic! You created something incredible!",
      "Excellent work! Your creation is awesome!",
      "Incredible! That's a magnificent dragon!",
    ];

    final randomPhrase = encouragingPhrases[
      DateTime.now().millisecondsSinceEpoch % encouragingPhrases.length
    ];

    try {
      await _flutterTts.speak(randomPhrase);
    } catch (e) {
      debugPrint('TTS failed: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS failed: $e');
    }
  }
}
