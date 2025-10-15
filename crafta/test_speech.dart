import 'package:flutter/material.dart';
import 'dart:io';
import 'lib/services/speech_service.dart';
import 'lib/services/ai_service.dart';
import 'lib/services/tts_service.dart';

void main() {
  runApp(SpeechTestApp());
}

class SpeechTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crafta Speech Test',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: SpeechTestScreen(),
    );
  }
}

class SpeechTestScreen extends StatefulWidget {
  @override
  _SpeechTestScreenState createState() => _SpeechTestScreenState();
}

class _SpeechTestScreenState extends State<SpeechTestScreen> {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  final TTSService _ttsService = TTSService();
  String _status = 'Initializing...';
  String _recognizedText = '';
  String _aiResponse = '';
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    setState(() => _status = 'Initializing services...');
    
    final speechSuccess = await _speechService.initialize();
    final ttsSuccess = await _ttsService.initialize();
    
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setState(() => _status = 'Desktop Mode: Use Mock Test buttons below');
    } else if (speechSuccess) {
      setState(() => _status = 'Speech recognition ready! Tap to test.');
    } else {
      setState(() => _status = 'Speech recognition failed. Check permissions.');
    }
  }

  Future<void> _testSpeech() async {
    setState(() {
      _isListening = true;
      _status = 'Listening... Speak now!';
    });

    await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _recognizedText = text;
          _status = 'Recognized: $text';
        });
        _processWithAI(text);
      },
      onError: (error) {
        setState(() {
          _status = 'Error: $error';
          _isListening = false;
        });
      },
    );

    // Auto-stop after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (_isListening) {
        _speechService.stopListening();
        setState(() {
          _isListening = false;
          _status = 'Test complete!';
        });
      }
    });
  }

  /// Mock test for desktop platforms
  Future<void> _testMockSpeech() async {
    const testPhrase = 'I want to create a rainbow cow with sparkles';
    
    setState(() {
      _recognizedText = testPhrase;
      _status = 'Mock Test: $testPhrase';
      _isProcessing = true;
    });

    await _processWithAI(testPhrase);
  }

  /// Process recognized text with AI
  Future<void> _processWithAI(String text) async {
    try {
      setState(() {
        _isProcessing = true;
        _status = 'Processing with AI...';
      });

      final aiResponse = await _aiService.getCraftaResponse(text);
      
      setState(() {
        _aiResponse = aiResponse;
        _status = 'AI Response received!';
        _isProcessing = false;
      });

      // Speak the response if TTS is available
      if (_ttsService.isAvailable) {
        _ttsService.speak(aiResponse);
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _status = 'AI processing failed';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D), // Crafta pink
        title: Text('Crafta Speech Test', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _status,
                style: TextStyle(fontSize: 16, color: Color(0xFF333333)),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 32),
            
            // Test Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Real Speech Test
                GestureDetector(
                  onTap: _testSpeech,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isListening 
                        ? const Color(0xFFFF6B9D) // Crafta pink when listening
                        : const Color(0xFF98D8C8), // Crafta mint when not listening
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening 
                            ? const Color(0xFFFF6B9D) 
                            : const Color(0xFF98D8C8)).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Mock Test Button
                GestureDetector(
                  onTap: _testMockSpeech,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _isProcessing 
                        ? const Color(0xFFFF6B9D) // Crafta pink when processing
                        : const Color(0xFF6B9D8C), // Different green for mock
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isProcessing 
                            ? const Color(0xFFFF6B9D) 
                            : const Color(0xFF6B9D8C)).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isProcessing ? Icons.psychology : Icons.smart_toy,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Instructions
            Text(
              _isListening 
                ? 'Listening... Speak now!'
                : _isProcessing
                  ? 'Processing with AI...'
                  : 'Left: Real Speech | Right: Mock Test',
              style: TextStyle(
                fontSize: 16,
                color: _isListening || _isProcessing
                  ? const Color(0xFFFF6B9D)
                  : const Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Recognized Text
            if (_recognizedText.isNotEmpty) ...[
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE0E0E0)),
                ),
                child: Text(
                  'Recognized: $_recognizedText',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
            
            // AI Response
            if (_aiResponse.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5), // Light pink background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B9D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crafta\'s Response:',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFFF6B9D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _aiResponse,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

