import 'package:flutter/material.dart';
import '../services/enhanced_voice_ai_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/ai_service.dart';
import '../theme/kid_friendly_theme.dart';

/// Voice-First Creator Screen
/// Designed for non-readers (4-10 year olds)
/// Single button to start, then pure voice interaction
/// Text field available as fallback only
class VoiceFirstCreator extends StatefulWidget {
  const VoiceFirstCreator({Key? key}) : super(key: key);

  @override
  State<VoiceFirstCreator> createState() => _VoiceFirstCreatorState();
}

class _VoiceFirstCreatorState extends State<VoiceFirstCreator> {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  final AIService _aiService = AIService();
  final EnhancedVoiceAIService _voiceAI = EnhancedVoiceAIService();
  final TextEditingController _textController = TextEditingController();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentInput = '';
  String _aiResponse = '';
  List<String> _conversationLog = [];

  // States
  bool _creationStarted = false;
  String _creationPhase = 'waiting'; // waiting, listening, processing, showing_result

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final speechReady = await _speechService.initialize();
      final ttsReady = await _ttsService.initialize();

      // AIService initializes globally via main.dart
      final aiReady = true;

      setState(() {
        _isInitialized = speechReady && ttsReady && aiReady;
      });

      if (_isInitialized) {
        // Play welcome sound
        await _ttsService.playWarmWelcome();
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _startCreation() async {
    if (!_isInitialized) {
      _showError('Services not ready. Please restart app.');
      return;
    }

    setState(() {
      _creationStarted = true;
      _conversationLog = [];
      _currentInput = '';
      _aiResponse = '';
    });

    // Greet and ask what to create
    await _ttsService.playWarmWelcome();
    await Future.delayed(const Duration(milliseconds: 500));

    await _askWhatToCreate();
  }

  Future<void> _askWhatToCreate() async {
    setState(() {
      _creationPhase = 'listening';
    });

    final prompt = 'What do you want to create? You can say anything like: a red dragon, a blue sword, a glowing house!';

    // Speak the question
    await _ttsService.speak(prompt);
    _addLog('🤖 Crafta: $prompt');

    // Wait for TTS to finish + buffer
    await Future.delayed(const Duration(seconds: 5));

    // Listen for user's response
    _addLog('🎤 Listening for your creation idea...');
    await _listenForCreation();
  }

  Future<void> _listenForCreation() async {
    try {
      setState(() {
        _isListening = true;
        _creationPhase = 'listening';
      });

      await _speechService.startListening(
        onResult: (result) async {
          if (result.isNotEmpty) {
            _addLog('👤 You said: $result');
            setState(() {
              _currentInput = result;
              _isListening = false;
            });

            // Process the creation request
            await _processCreationRequest(result);
          }
        },
        onError: (error) {
          _addLog('❌ Error listening: $error');
          setState(() {
            _isListening = false;
          });
        },
      );

      // Wait for result with timeout
      await Future.delayed(const Duration(seconds: 16));

      if (_isListening) {
        _addLog('⏱️ No speech detected. Try again!');
        setState(() {
          _isListening = false;
        });
        await _askWhatToCreate();
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _processCreationRequest(String userInput) async {
    setState(() {
      _creationPhase = 'processing';
      _isProcessing = true;
    });

    try {
      _addLog('⏳ Crafta is thinking...');
      await _ttsService.playThinkingSound();

      // Ask AI to create based on user input
      final response = await EnhancedVoiceAIService.generateVoiceResponse(
        'Create a minecraft creature based on this description: $userInput'
      );

      setState(() {
        _aiResponse = response;
        _creationPhase = 'showing_result';
        _isProcessing = false;
      });

      _addLog('🤖 Crafta: $response');

      // Speak the response
      await _ttsService.speak(response);

      // Ask if they want to export or create another
      await Future.delayed(const Duration(seconds: 2));
      await _askWhatNext();
    } catch (e) {
      _addLog('❌ Error processing: $e');
      setState(() {
        _isProcessing = false;
      });
      await _ttsService.speak('Oops! Something went wrong. Let me try again!');
      await Future.delayed(const Duration(seconds: 2));
      await _askWhatToCreate();
    }
  }

  Future<void> _askWhatNext() async {
    const prompt = 'Do you want to create something else? Say yes to create again!';

    await _ttsService.speak(prompt);
    _addLog('🤖 Crafta: $prompt');

    // Wait for TTS
    await Future.delayed(const Duration(seconds: 3));

    // Listen for response
    await _speechService.startListening(
      onResult: (result) async {
        if (result.toLowerCase().contains('yes') ||
            result.toLowerCase().contains('again') ||
            result.toLowerCase().contains('create')) {
          _addLog('👤 You said: $result');
          await _askWhatToCreate();
        } else {
          _addLog('👤 You said: $result');
          await _ttsService.speak('Thanks for creating! Goodbye!');
          setState(() {
            _creationStarted = false;
          });
        }
      },
      onError: (error) {
        _addLog('❌ Error: $error');
      },
    );

    await Future.delayed(const Duration(seconds: 10));
  }

  Future<void> _handleTextInput() async {
    if (_textController.text.isEmpty) return;

    final userInput = _textController.text;
    _textController.clear();

    _addLog('👤 You typed: $userInput');
    setState(() {
      _currentInput = userInput;
      _creationPhase = 'processing';
      _isProcessing = true;
    });

    await _processCreationRequest(userInput);
  }

  void _addLog(String message) {
    print('VOICE_CREATOR: $message');
    setState(() {
      _conversationLog.insert(0, message);
      if (_conversationLog.length > 15) {
        _conversationLog.removeLast();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidFriendlyTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('✨ Create with Voice ✨'),
        backgroundColor: KidFriendlyTheme.primaryPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Call-to-Action Button
            if (!_creationStarted) ...[
              const SizedBox(height: 40),
              _buildBigStartButton(),
              const SizedBox(height: 40),
              _buildInfoSection(),
            ] else ...[
              // Active Creation Session
              _buildConversationArea(),
              const SizedBox(height: 20),
              _buildTextInputFallback(),
              const SizedBox(height: 20),
              _buildConversationLog(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBigStartButton() {
    return GestureDetector(
      onTap: _isInitialized ? _startCreation : null,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              KidFriendlyTheme.primaryPurple,
              KidFriendlyTheme.primaryBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: KidFriendlyTheme.primaryPurple.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎨',
              style: TextStyle(
                fontSize: 80,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'START CREATING',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KidFriendlyTheme.backgroundBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KidFriendlyTheme.primaryBlue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            '🎤 Just Press START',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: KidFriendlyTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Then tell Crafta what you want to create!',
            style: TextStyle(
              fontSize: 18,
              color: KidFriendlyTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Examples:\n"A red dragon"\n"A blue glowing sword"\n"A rainbow house"',
            style: TextStyle(
              fontSize: 16,
              color: KidFriendlyTheme.textMedium,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KidFriendlyTheme.primaryPurple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPhaseColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getPhaseText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Current user input
          if (_currentInput.isNotEmpty) ...[
            Text(
              '👤 You said:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentInput,
              style: TextStyle(
                fontSize: 18,
                color: KidFriendlyTheme.textDark,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // AI Response
          if (_aiResponse.isNotEmpty) ...[
            Text(
              '🤖 Crafta says:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _aiResponse,
              style: TextStyle(
                fontSize: 18,
                color: KidFriendlyTheme.textDark,
              ),
            ),
          ],

          // Processing indicator
          if (_isProcessing) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        KidFriendlyTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Creating your masterpiece...',
                    style: TextStyle(
                      fontSize: 14,
                      color: KidFriendlyTheme.textMedium,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextInputFallback() {
    if (!_creationStarted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or type instead of speaking:',
          style: TextStyle(
            fontSize: 12,
            color: KidFriendlyTheme.textMedium,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !_isProcessing && !_isListening,
                decoration: InputDecoration(
                  hintText: 'Type what to create...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: (!_isProcessing && !_isListening)
                  ? _handleTextInput
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('✓'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConversationLog() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation Log:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: KidFriendlyTheme.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          ..._conversationLog.map((msg) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    switch (_creationPhase) {
      case 'listening':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'showing_result':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPhaseText() {
    switch (_creationPhase) {
      case 'listening':
        return '🎤 Listening...';
      case 'processing':
        return '✨ Creating...';
      case 'showing_result':
        return '✅ Created!';
      default:
        return 'Ready';
    }
  }
}
