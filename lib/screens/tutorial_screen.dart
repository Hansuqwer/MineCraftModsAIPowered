import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../theme/minecraft_theme.dart';

/// Interactive Tutorial Screen
/// Guides new users through the app features
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStepIndex = 0;
  bool _isListening = false;
  // Removed unused _isProcessing field
  String? _lastSpeechResult;

  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  final List<TutorialStep> _steps = TutorialService.getTutorialSteps();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTutorialProgress();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  Future<void> _loadTutorialProgress() async {
    final currentStep = await TutorialService.getCurrentStep();
    setState(() {
      _currentStepIndex = currentStep;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: MinecraftTheme.stoneGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildTutorialContent(currentStep),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildNavigationButtons(currentStep),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _skipTutorial,
              ),
              const Spacer(),
              Text(
                'Tutorial ${_currentStepIndex + 1}/${_steps.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance the close button
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_steps[_currentStepIndex].color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialContent(TutorialStep step) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: step.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: value * 0.1,
                  child: Icon(
                    step.icon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  step.action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (step.isInteractive) ...[
            const SizedBox(height: 24),
            _buildInteractiveSection(step),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveSection(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (step.interactiveAction == TutorialAction.speak) ...[
            _buildSpeechInterface(step),
          ] else if (step.interactiveAction == TutorialAction.tap) ...[
            _buildTapInterface(step),
          ],
          if (_lastSpeechResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Great! You said: "$_lastSpeechResult"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSpeechInterface(TutorialStep step) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _isListening ? Colors.red : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening ? 'Listening...' : 'Tap to speak',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (step.interactiveText != null) ...[
          const SizedBox(height: 8),
          Text(
            'Try saying: "${step.interactiveText}"',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTapInterface(TutorialStep step) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(
            Icons.touch_app,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the button when ready',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStepIndex > 0)
            Expanded(
              child: _buildButton(
                text: 'Previous',
                onPressed: _previousStep,
                color: Colors.white.withOpacity(0.8),
                textColor: step.color,
              ),
            ),
          if (_currentStepIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              text: step.id == 'tutorial_complete' ? 'Complete' : 'Next',
              onPressed: step.id == 'tutorial_complete' ? _completeTutorial : _nextStep,
              color: Colors.white,
              textColor: step.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    try {
      final result = await _speechService.listen();
      setState(() {
        _lastSpeechResult = result;
        _isListening = false;
      });

      // Check if the speech matches the expected input
      final currentStep = _steps[_currentStepIndex];
      if (result != null && result.toLowerCase().contains(currentStep.interactiveText?.toLowerCase() ?? '')) {
        await _ttsService.speak('Perfect! You got it right!');
        await Future.delayed(const Duration(seconds: 2));
        _nextStep();
      } else {
        await _ttsService.speak('Good try! Let\'s continue to the next step.');
        await Future.delayed(const Duration(seconds: 2));
        _nextStep();
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      await _ttsService.speak('No worries! Let\'s continue.');
      _nextStep();
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _nextStep() async {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _lastSpeechResult = null;
      });
      await TutorialService.setCurrentStep(_currentStepIndex);
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _lastSpeechResult = null;
      });
      await TutorialService.setCurrentStep(_currentStepIndex);
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _completeTutorial() async {
    await TutorialService.markTutorialCompleted();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _skipTutorial() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Tutorial'),
        content: const Text('Are you sure you want to skip the tutorial? You can always access it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TutorialService.markTutorialSkipped();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
