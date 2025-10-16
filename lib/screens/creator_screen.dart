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

class _CreatorScreenState extends State<CreatorScreen>
    with TickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  final TTSService _ttsService = TTSService();
  Conversation _conversation = Conversation(messages: []);
  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentCreatureType = '';
  List<String> _creatureSuggestions = [];
  int _userAge = 6; // Default age for suggestions
  
  late AnimationController _micController;
  late AnimationController _sparkleController;
  late Animation<double> _micAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
  }

  void _initializeAnimations() {
    // Microphone animation
    _micController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _micAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _micController,
      curve: Curves.easeInOut,
    ));
    
    // Sparkle animation for Crafta's avatar
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _sparkleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _micController.dispose();
    _sparkleController.dispose();
    super.dispose();
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
    
    // Load creature suggestions
    _loadCreatureSuggestions();
  }

  void _loadCreatureSuggestions() {
    setState(() {
      _creatureSuggestions = _aiService.getAgeAppropriateSuggestions(_userAge);
    });
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
    print('DEBUG: Mock speech test button pressed!');
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
      print('DEBUG: Parsed attributes: $attributes');
      
      // Validate content for age
      final isAgeAppropriate = _aiService.validateContentForAge(testPhrase, _userAge);
      print('DEBUG: Age appropriate for $_userAge: $isAgeAppropriate');
      
      if (attributes['creatureType'] != null && attributes['color'] != null && isAgeAppropriate) {
        _conversation = _conversation.markComplete(attributes);
        
        // Show visual preview first
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            print('DEBUG: Navigating to creature preview with: $attributes');
            Navigator.pushNamed(
              context,
              '/creature-preview',
              arguments: {
                'creatureAttributes': attributes,
                'creatureName': '${attributes['color']} ${attributes['creatureType']}',
              },
            );
          }
        });
      } else {
        print('DEBUG: Not enough attributes - creatureType: ${attributes['creatureType']}, color: ${attributes['color']}');
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

  void _useSuggestion(String suggestion) async {
    setState(() {
      _isProcessing = true;
      _recognizedText = suggestion;
    });

    // Play thinking sound
    _ttsService.playThinkingSound();

    // Get AI response
    try {
      final aiResponse = await _aiService.getCraftaResponse(suggestion);
      _conversation = _conversation.addMessage(aiResponse, false);
      
      // Speak Crafta's response
      _ttsService.speak(aiResponse);
      
      // Check if we have enough info to create the creature
      final attributes = _aiService.parseCreatureRequest(suggestion);
      print('DEBUG: Suggestion parsed attributes: $attributes');
      
      // Validate content for age
      final isAgeAppropriate = _aiService.validateContentForAge(suggestion, _userAge);
      print('DEBUG: Suggestion age appropriate for $_userAge: $isAgeAppropriate');
      
      if (attributes['creatureType'] != null && attributes['color'] != null && isAgeAppropriate) {
        _conversation = _conversation.markComplete(attributes);
        
        // Play creature sound
        _ttsService.playCreatureSound(attributes['creatureType']);
        
        // Show visual preview first
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            print('DEBUG: Navigating to creature preview from suggestion with: $attributes');
            Navigator.pushNamed(
              context,
              '/creature-preview',
              arguments: {
                'creatureAttributes': attributes,
                'creatureName': '${attributes['color']} ${attributes['creatureType']}',
              },
            );
          }
        });
      } else {
        print('DEBUG: Suggestion not enough attributes - creatureType: ${attributes['creatureType']}, color: ${attributes['color']}');
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
                    // Animated Crafta Avatar
                    AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _sparkleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF98D8C8), // Crafta mint
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF98D8C8).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
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
                    // Animated Microphone Button
                    AnimatedBuilder(
                      animation: _micAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _micAnimation.value : 1.0,
                          child: GestureDetector(
                            onTapDown: (_) {
                              _startListening();
                              _micController.repeat(reverse: true);
                            },
                            onTapUp: (_) {
                              _stopListening();
                              _micController.stop();
                            },
                            onTapCancel: () {
                              _stopListening();
                              _micController.stop();
                            },
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
                                      : const Color(0xFF98D8C8)).withOpacity(0.4),
                                    blurRadius: _isListening ? 20 : 12,
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
                        );
                      },
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
                    
                    // Creature Suggestions
                    if (_creatureSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '💡 Try saying:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _creatureSuggestions.take(3).map((suggestion) {
                          return GestureDetector(
                            onTap: () => _useSuggestion(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF98D8C8).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF98D8C8),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                onPressed: () {
                  print('DEBUG: Mock speech button tapped!');
                  _testMockSpeech();
                },
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
