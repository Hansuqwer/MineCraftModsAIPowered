import 'package:flutter/material.dart';
import '../services/enhanced_speech_service.dart';
import '../services/enhanced_tts_service.dart';
import '../widgets/voice_feedback_widget.dart';

/// Voice calibration screen for first-time voice setup
/// Guides kids through testing their microphone and voice
class VoiceCalibrationScreen extends StatefulWidget {
  const VoiceCalibrationScreen({Key? key}) : super(key: key);

  @override
  State<VoiceCalibrationScreen> createState() => _VoiceCalibrationScreenState();
}

class _VoiceCalibrationScreenState extends State<VoiceCalibrationScreen>
    with SingleTickerProviderStateMixin {
  final EnhancedSpeechService _speechService = EnhancedSpeechService();
  final EnhancedTTSService _ttsService = EnhancedTTSService();

  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  bool _isInitialized = false;
  bool _isCalibrating = false;
  double _calibrationProgress = 0.0;
  String _currentInstruction = '';
  String _statusMessage = 'Tap "Start" to set up your voice!';
  bool _calibrationComplete = false;
  double _finalCalibrationLevel = 0.0;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final speechInit = await _speechService.initialize();
    final ttsInit = await _ttsService.initialize();

    setState(() {
      _isInitialized = speechInit && ttsInit;
    });

    if (_isInitialized) {
      await _ttsService.speak('Hi there! Let\'s set up your voice so I can hear you perfectly!');
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _startCalibration() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Services not initialized. Please try again.')),
      );
      return;
    }

    setState(() {
      _isCalibrating = true;
      _calibrationProgress = 0.0;
      _calibrationComplete = false;
    });

    final result = await _speechService.calibrateVoice(
      onInstruction: (instruction) {
        setState(() {
          _currentInstruction = instruction;
        });
        _ttsService.speak(instruction);
      },
      onProgress: (progress) {
        setState(() {
          _calibrationProgress = progress;
        });
      },
    );

    setState(() {
      _isCalibrating = false;
      _calibrationComplete = result.success;
      _finalCalibrationLevel = result.calibrationLevel;
      _statusMessage = result.message;
    });

    if (result.success) {
      _celebrationController.forward();
      await _ttsService.playCelebrationSound();
    } else {
      await _ttsService.speak('Don\'t worry! Let\'s try again when you\'re ready.');
    }
  }

  void _finish() {
    Navigator.of(context).pop(_calibrationComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Setup'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        '🎤 Voice Setup',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status card
                      _buildStatusCard(),
                      const SizedBox(height: 24),

                      // Voice feedback visualization
                      if (_isCalibrating)
                        VoiceFeedbackWidget(
                          isListening: _isCalibrating,
                          soundLevel: _calibrationProgress,
                          style: VoiceFeedbackStyle.pulse,
                        ),

                      // Celebration animation
                      if (_calibrationComplete)
                        _buildCelebration(),

                      const SizedBox(height: 32),

                      // Progress indicator
                      if (_isCalibrating)
                        _buildProgressIndicator(),

                      const SizedBox(height: 24),

                      // Instructions
                      _buildInstructions(),

                      const SizedBox(height: 32),

                      // Tips card
                      if (!_isCalibrating && !_calibrationComplete)
                        _buildTipsCard(),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              _calibrationComplete ? Icons.check_circle : Icons.mic,
              size: 64,
              color: _calibrationComplete ? Colors.green : Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_calibrationComplete) ...[
              const SizedBox(height: 16),
              _buildCalibrationScore(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationScore() {
    final percentage = (_finalCalibrationLevel * 100).toInt();
    String scoreText = '';
    Color scoreColor = Colors.grey;

    if (percentage >= 80) {
      scoreText = '🌟 Excellent!';
      scoreColor = Colors.green;
    } else if (percentage >= 60) {
      scoreText = '👍 Good!';
      scoreColor = Colors.blue;
    } else {
      scoreText = '✓ Basic';
      scoreColor = Colors.orange;
    }

    return Column(
      children: [
        Text(
          scoreText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _finalCalibrationLevel,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildCelebration() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationAnimation.value,
          child: Column(
            children: [
              Text(
                '🎉',
                style: TextStyle(fontSize: 80 * _celebrationAnimation.value),
              ),
              const SizedBox(height: 16),
              Text(
                'Perfect!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _calibrationProgress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text(
          '${(_calibrationProgress * 100).toInt()}% Complete',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    if (_currentInstruction.isEmpty && !_calibrationComplete) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              _calibrationComplete ? Icons.celebration : Icons.hearing,
              size: 32,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _currentInstruction.isNotEmpty
                    ? _currentInstruction
                    : 'All done! Your voice is ready!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 4,
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tips for Best Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('🔇', 'Find a quiet place'),
            _buildTipItem('📱', 'Hold device close (but not too close!)'),
            _buildTipItem('🗣️', 'Speak clearly and naturally'),
            _buildTipItem('🎤', 'Listen to Crafta\'s instructions'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_calibrationComplete)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startCalibration,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_calibrationComplete) const SizedBox(width: 12),
          Expanded(
            flex: _calibrationComplete ? 2 : 1,
            child: ElevatedButton.icon(
              onPressed: _isCalibrating
                  ? null
                  : (_calibrationComplete ? _finish : _startCalibration),
              icon: Icon(
                _calibrationComplete
                    ? Icons.check
                    : (_isCalibrating ? Icons.mic : Icons.play_arrow),
              ),
              label: Text(
                _calibrationComplete
                    ? 'Finish'
                    : (_isCalibrating ? 'Calibrating...' : 'Start Calibration'),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _calibrationComplete
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
