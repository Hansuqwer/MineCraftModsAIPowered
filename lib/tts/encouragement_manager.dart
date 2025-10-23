import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class EncouragementManager {
  static final EncouragementManager _i = EncouragementManager._();
  factory EncouragementManager() => _i;
  EncouragementManager._();

  final _tts = FlutterTts();
  final _player = AudioPlayer();
  final _rand = Random();

  final _phrases = const [
    "That looks awesome!",
    "Wow, you're so creative!",
    "Great choice!",
    "Your imagination is amazing!",
    "Fantastic work!",
  ];

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.8);
    await _tts.setPitch(1.1);
    await _tts.setVolume(0.9);
  }

  Future<void> celebrate() async {
    try {
      // optional: add a short bell at assets/sounds/sparkle.mp3 and include in pubspec
      // await _player.play(AssetSource('sounds/sparkle.mp3'));
      await _tts.stop();
      await _tts.speak(_phrases[_rand.nextInt(_phrases.length)]);
    } catch (e) {
      debugPrint('Encouragement error: $e');
    }
  }
}
