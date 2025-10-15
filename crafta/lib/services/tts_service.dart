import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class TTSService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;

  /// Initialize TTS
  Future<bool> initialize() async {
    // On desktop platforms, TTS may not be available
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print('TTS not available on desktop platforms');
      _isInitialized = false;
      return false;
    }

    _flutterTts = FlutterTts();
    
    try {
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setSpeechRate(0.8); // Slightly slower for kids
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.1); // Slightly higher pitch for friendly voice
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('TTS initialization error: $e');
      return false;
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('TTS not initialized');
      return;
    }

    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts!.stop();
    }
  }

  /// Check if TTS is available
  bool get isAvailable => _isInitialized;
}
