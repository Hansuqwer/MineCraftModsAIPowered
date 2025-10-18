import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../models/conversation.dart';

/// Simple Creator Screen - Working version
class CreatorScreenSimple extends StatefulWidget {
  const CreatorScreenSimple({super.key});

  @override
  State<CreatorScreenSimple> createState() => _CreatorScreenSimpleState();
}

class _CreatorScreenSimpleState extends State<CreatorScreenSimple> {
  final AIService _aiService = AIService();
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  final TextEditingController _textController = TextEditingController();
  
  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;
  Conversation _conversation = Conversation(messages: []);

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    
    setState(() => _isListening = true);
    
    await _speechService.startListening(
      onResult: (text) {
        setState(() => _recognizedText = text);
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() => _isListening = false);
      },
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    
    await _speechService.stopListening();
    setState(() => _isListening = false);
    
    if (_recognizedText.isNotEmpty) {
      await _processTextInput(_recognizedText);
    }
  }

  Future<void> _processTextInput(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Add user message to conversation
      _conversation = _conversation.addMessage(text, true);
      
      // Get AI response
      final response = await _aiService.getCraftaResponse(text);
      
      // Add AI response to conversation
      _conversation = _conversation.addMessage(response, false);
      
      // Speak the response
      await _ttsService.speak(response);
      
      setState(() {
        _isProcessing = false;
      });
      
    } catch (e) {
      print('Error processing text: $e');
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D),
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
              // Crafta Avatar
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF98D8C8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
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
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _recognizedText.isEmpty 
                    ? 'Hi! I\'m Crafta! What would you like to create today?'
                    : _recognizedText,
                  style: TextStyle(
                    fontSize: 16,
                    color: _recognizedText.isEmpty 
                      ? const Color(0xFF333333)
                      : const Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
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
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFF98D8C8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening 
                          ? const Color(0xFFFF6B9D)
                          : const Color(0xFF98D8C8)).withOpacity(0.4),
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
              
              // Status Text
              Text(
                _isListening 
                  ? 'Listening... Tap and hold to speak'
                  : 'Tap and hold the microphone to talk to Crafta',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Text Input Alternative
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Or type your message:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Describe what you want to create...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: _processTextInput,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _processTextInput(_textController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98D8C8),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
              
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF98D8C8)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Creating your creature...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
