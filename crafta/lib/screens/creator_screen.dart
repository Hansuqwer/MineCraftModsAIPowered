import 'package:flutter/material.dart';
import 'dart:io';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../models/conversation.dart';

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  final TTSService _ttsService = TTSService();
  Conversation _conversation = Conversation(messages: []);
  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final speechSuccess = await _speechService.initialize();
    final ttsSuccess = await _ttsService.initialize();
    
    // Only show microphone error on mobile platforms
    if (!speechSuccess && (Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('I can\'t hear you right now. Let\'s check your microphone!'),
          backgroundColor: Color(0xFFFF6B9D), // Crafta pink instead of red
        ),
      );
    }
    
    // Start the conversation with Crafta's welcome message
    final welcomeMessage = 'Hi! What would you like to create today?';
    _conversation = _conversation.addMessage(welcomeMessage, false);
    
    // Speak the welcome message (only if TTS is available)
    if (ttsSuccess) {
      _ttsService.speak(welcomeMessage);
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speechService.startListening(
      onResult: (text) {
        setState(() {
          _recognizedText = text;
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops! Let\'s try that again. What would you like to create?'),
            backgroundColor: const Color(0xFF98D8C8), // Crafta mint
          ),
        );
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    
    if (_recognizedText.isNotEmpty) {
      // Add user message to conversation
      _conversation = _conversation.addMessage(_recognizedText, true);
      
      // Get AI response
      try {
        final aiResponse = await _aiService.getCraftaResponse(_recognizedText);
        _conversation = _conversation.addMessage(aiResponse, false);
        
        // Speak Crafta's response
        _ttsService.speak(aiResponse);
        
        // Check if we have enough info to create the creature
        final attributes = _aiService.parseCreatureRequest(_recognizedText);
        if (attributes['creatureType'] != null && attributes['color'] != null) {
          _conversation = _conversation.markComplete(attributes);
          
          // Navigate to complete screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamed(
                context,
                '/complete',
                arguments: {
                  'creatureName': '${attributes['color']} ${attributes['creatureType']}',
                  'creatureType': attributes['creatureType'],
                  'creatureAttributes': '${attributes['color']} color with ${attributes['effects'].join(' and ')}',
                },
              );
            }
          });
        }
      } catch (e) {
        final errorMessage = 'Oops! Let\'s try that again - what would you like to create?';
        _conversation = _conversation.addMessage(errorMessage, false);
        _ttsService.speak(errorMessage);
      }
    }
    
    setState(() {
      _isProcessing = false;
    });
  }

  /// Mock speech test for development
  Future<void> _testMockSpeech() async {
    // Simulate speech recognition with a test phrase
    const testPhrase = 'I want to create a rainbow cow with sparkles';
    
    setState(() {
      _recognizedText = testPhrase;
      _isProcessing = true;
    });
    
    // Add user message to conversation
    _conversation = _conversation.addMessage(testPhrase, true);
    
    // Get AI response
    try {
      final aiResponse = await _aiService.getCraftaResponse(testPhrase);
      _conversation = _conversation.addMessage(aiResponse, false);
      
      // Speak Crafta's response
      _ttsService.speak(aiResponse);
      
      // Check if we have enough info to create the creature
      final attributes = _aiService.parseCreatureRequest(testPhrase);
      if (attributes['creatureType'] != null && attributes['color'] != null) {
        _conversation = _conversation.markComplete(attributes);
        
        // Navigate to complete screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/complete',
              arguments: {
                'creatureName': '${attributes['color']} ${attributes['creatureType']}',
                'creatureType': attributes['creatureType'],
                'creatureAttributes': '${attributes['color']} color with ${attributes['effects'].join(' and ')}',
              },
            );
          }
        });
      }
    } catch (e) {
      final errorMessage = 'Oops! Let\'s try that again - what would you like to create?';
      _conversation = _conversation.addMessage(errorMessage, false);
      _ttsService.speak(errorMessage);
    }
    
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D), // Crafta pink
        title: const Text(
          'Crafta Creator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Crafta Avatar and Speech Bubble
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Crafta Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF98D8C8), // Crafta mint
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Speech Bubble
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_isProcessing)
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Crafta is thinking...'),
                              ],
                            )
                          else
                            Text(
                              _conversation.lastCraftaMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF333333),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Voice Input Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone Button
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      onTapCancel: () => _stopListening(),
                      child: Container(
                        width: 120,
                        height: 120,
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Instructions
                    Text(
                      _isListening 
                        ? 'Listening... Speak now!'
                        : 'Hold to speak',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isListening 
                          ? const Color(0xFFFF6B9D)
                          : const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    // Recognized Text
                    if (_recognizedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Text(
                          _recognizedText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Start Over Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _recognizedText = '';
                    _conversation = Conversation(messages: []);
                  });
                },
                child: const Text(
                  'Start Over',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Mock Speech Test Button (for development)
              const SizedBox(height: 8),
              TextButton(
                onPressed: _testMockSpeech,
                child: const Text(
                  '🧪 Test Speech (Mock)',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
