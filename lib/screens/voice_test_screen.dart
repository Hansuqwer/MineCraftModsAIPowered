import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/kid_friendly_theme.dart';

/// Simple Voice Testing Screen for T1.1, T1.2 testing
/// Verifies Speech-to-Text and Text-to-Speech work properly
class VoiceTestScreen extends StatefulWidget {
  const VoiceTestScreen({Key? key}) : super(key: key);

  @override
  State<VoiceTestScreen> createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();

  bool _speechInitialized = false;
  bool _ttsInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  String _testStatus = 'Not started';
  List<String> _testLog = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _addLog('Starting voice service initialization...');

    try {
      // Initialize speech service
      _addLog('Initializing Speech-to-Text service...');
      final speechReady = await _speechService.initialize();
      setState(() {
        _speechInitialized = speechReady;
      });
      _addLog('Speech-to-Text: ${speechReady ? '✅ Ready' : '❌ Failed'}');

      // Initialize TTS service
      _addLog('Initializing Text-to-Speech service...');
      final ttsReady = await _ttsService.initialize();
      setState(() {
        _ttsInitialized = ttsReady;
      });
      _addLog('Text-to-Speech: ${ttsReady ? '✅ Ready' : '❌ Failed'}');

      if (speechReady && ttsReady) {
        setState(() {
          _testStatus = 'Ready for testing';
        });
        _addLog('✅ Both services ready!');

        // Play welcome message
        await _ttsService.playWarmWelcome();
      } else {
        setState(() {
          _testStatus = 'Service initialization failed';
        });
        _addLog('❌ One or more services failed to initialize');
      }
    } catch (e) {
      _addLog('❌ Initialization error: $e');
      setState(() {
        _testStatus = 'Initialization error: $e';
      });
    }
  }

  void _addLog(String message) {
    print('🎤 VOICE TEST: $message');
    setState(() {
      _testLog.insert(0, '${DateTime.now().toString().split('.')[0]} - $message');
      if (_testLog.length > 20) {
        _testLog.removeLast();
      }
    });
  }

  Future<void> _testSpeechInput() async {
    if (!_speechInitialized) {
      _addLog('❌ Speech service not initialized');
      return;
    }

    _addLog('🎤 Starting speech recognition...');
    _addLog('⏳ Give it 2-3 seconds after AI finishes speaking, then speak clearly');
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    try {
      await _speechService.startListening(
        onResult: (result) {
          // ECHO CANCELLATION: Ignore if result contains common AI greeting phrases
          if (_isLikelyEcho(result)) {
            _addLog('⚠️ Echo detected - ignoring AI voice: $result');
            return;
          }

          _addLog('✅ Speech recognized: $result');
          setState(() {
            _recognizedText = result;
            _isListening = false;
          });
        },
        onError: (error) {
          _addLog('❌ Speech error: $error');
          setState(() {
            _isListening = false;
          });
        },
      );

      // Wait for result with timeout
      await Future.delayed(const Duration(seconds: 15));

      if (_isListening) {
        _addLog('⏱️ Timeout - no speech detected');
        await _speechService.stopListening();
        setState(() {
          _isListening = false;
        });
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  // ECHO CANCELLATION: Detect if the recognized text is likely the AI speaking, not user
  bool _isLikelyEcho(String recognized) {
    final lowerRecognized = recognized.toLowerCase();

    // Common phrases the AI says - if we recognize these, it's probably echo
    final aiPhrases = [
      'hello i am crafta',
      'please say something',
      'you said',
      'great job you are amazing',
      'test spoken successfully',
    ];

    for (final phrase in aiPhrases) {
      if (lowerRecognized.contains(phrase)) {
        return true; // Likely echo from AI speaking
      }
    }

    return false; // Likely user speaking
  }

  Future<void> _testTextOutput(String text) async {
    if (!_ttsInitialized) {
      _addLog('❌ TTS service not initialized');
      return;
    }

    _addLog('🔊 Speaking: "$text"');
    try {
      await _ttsService.speak(text);
      _addLog('✅ Text spoken successfully');
    } catch (e) {
      _addLog('❌ TTS error: $e');
    }
  }

  Future<void> _testVoiceLoop() async {
    _addLog('=== TESTING COMPLETE VOICE LOOP ===');
    _addLog('Step 1: Speaking test message');

    await _testTextOutput('Hello! I am Crafta. Please say something!');

    // CRITICAL FIX: Wait longer for TTS to finish before listening
    // This prevents microphone from picking up the AI's own voice
    _addLog('⏳ Waiting for TTS to finish (5 seconds)...');
    await Future.delayed(const Duration(seconds: 5));

    _addLog('Step 2: Listening for your response');
    await _testSpeechInput();
    await Future.delayed(const Duration(seconds: 16));

    if (_recognizedText.isNotEmpty) {
      _addLog('Step 3: Echoing what you said');
      await _testTextOutput('You said: $_recognizedText');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidFriendlyTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Voice Service Test (T1.1 & T1.2)'),
        backgroundColor: KidFriendlyTheme.primaryPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Cards
            _buildStatusCard('Speech-to-Text', _speechInitialized),
            const SizedBox(height: 12),
            _buildStatusCard('Text-to-Speech', _ttsInitialized),
            const SizedBox(height: 16),

            // Overall Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testStatus == 'Ready for testing'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: _testStatus == 'Ready for testing'
                      ? Colors.green
                      : Colors.orange,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _testStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _testStatus == 'Ready for testing'
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recognized Text Display
            if (_recognizedText.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KidFriendlyTheme.primaryBlue.withOpacity(0.1),
                  border: Border.all(
                    color: KidFriendlyTheme.primaryBlue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recognized Text:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Test Buttons
            const Text(
              'Individual Tests:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _speechInitialized && !_isListening
                  ? _testSpeechInput
                  : null,
              icon: const Icon(Icons.mic),
              label: Text(_isListening ? 'Listening...' : 'Test Speech Input'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryBlue,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _ttsInitialized
                  ? () => _testTextOutput('Hello! This is Crafta speaking!')
                  : null,
              icon: const Icon(Icons.volume_up),
              label: const Text('Test TTS: Hello'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryGreen,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _ttsInitialized
                  ? () => _testTextOutput('Great job! You are amazing!')
                  : null,
              icon: const Icon(Icons.celebration),
              label: const Text('Test TTS: Celebration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryOrange,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Complete Loop Test
            const Text(
              'Integration Test:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: (_speechInitialized && _ttsInitialized && !_isListening)
                  ? _testVoiceLoop
                  : null,
              icon: const Icon(Icons.repeat),
              label: const Text('Test Complete Voice Loop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryPurple,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Test Log
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Log:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _testLog.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _testLog[index],
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, bool isReady) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        border: Border.all(
          color: isReady ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            isReady ? '✅' : '❌',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isReady ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
