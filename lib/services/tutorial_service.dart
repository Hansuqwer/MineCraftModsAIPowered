import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tutorial Service
/// Manages interactive tutorials and onboarding for new users
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _tutorialStepKey = 'tutorial_step';
  static const String _tutorialSkippedKey = 'tutorial_skipped';

  /// Check if tutorial has been completed
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Check if tutorial was skipped
  static Future<bool> isTutorialSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialSkippedKey) ?? false;
  }

  /// Mark tutorial as skipped
  static Future<void> markTutorialSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialSkippedKey, true);
  }

  /// Get current tutorial step
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tutorialStepKey) ?? 0;
  }

  /// Set current tutorial step
  static Future<void> setCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tutorialStepKey, step);
  }

  /// Reset tutorial progress
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_tutorialStepKey);
    await prefs.remove(_tutorialSkippedKey);
  }

  /// Get all tutorial steps
  static List<TutorialStep> getTutorialSteps() {
    return [
      TutorialStep(
        id: 'welcome',
        title: 'Welcome to Crafta!',
        description: 'I\'m your AI friend who helps you create amazing Minecraft creatures!',
        action: 'Tap the microphone and say "Hello Crafta!"',
        icon: Icons.waving_hand,
        color: Colors.blue,
        isInteractive: true,
        interactiveAction: TutorialAction.speak,
        interactiveText: 'Hello Crafta!',
      ),
      TutorialStep(
        id: 'voice_training',
        title: 'Voice Training',
        description: 'Speak clearly so I can understand you better. Try saying your name!',
        action: 'Say "My name is [your name]"',
        icon: Icons.mic,
        color: Colors.green,
        isInteractive: true,
        interactiveAction: TutorialAction.speak,
        interactiveText: 'My name is',
      ),
      TutorialStep(
        id: 'first_creature',
        title: 'Create Your First Creature',
        description: 'Let\'s create something amazing together! Try asking for a friendly dragon.',
        action: 'Say "Create a friendly dragon"',
        icon: Icons.pets,
        color: Colors.purple,
        isInteractive: true,
        interactiveAction: TutorialAction.speak,
        interactiveText: 'Create a friendly dragon',
      ),
      TutorialStep(
        id: 'customize_creature',
        title: 'Customize Your Creature',
        description: 'Make it special! Try asking for different colors or effects.',
        action: 'Say "Make it blue with sparkles"',
        icon: Icons.palette,
        color: Colors.orange,
        isInteractive: true,
        interactiveAction: TutorialAction.speak,
        interactiveText: 'Make it blue with sparkles',
      ),
      TutorialStep(
        id: 'view_3d',
        title: 'View in 3D',
        description: 'See how your creature looks in Minecraft! Tap the 3D button.',
        action: 'Tap the "VIEW IN 3D" button',
        icon: Icons.view_in_ar,
        color: Colors.cyan,
        isInteractive: true,
        interactiveAction: TutorialAction.tap,
        interactiveTarget: 'view_3d_button',
      ),
      TutorialStep(
        id: 'export_minecraft',
        title: 'Export to Minecraft',
        description: 'Ready to use your creature in Minecraft? Let\'s export it!',
        action: 'Tap "Export to Minecraft"',
        icon: Icons.download,
        color: Colors.red,
        isInteractive: true,
        interactiveAction: TutorialAction.tap,
        interactiveTarget: 'export_button',
      ),
      TutorialStep(
        id: 'tutorial_complete',
        title: 'You\'re All Set!',
        description: 'Amazing! You\'ve learned how to use Crafta. Now create anything you can imagine!',
        action: 'Start creating!',
        icon: Icons.celebration,
        color: Colors.amber,
        isInteractive: false,
      ),
    ];
  }

  /// Get tutorial step by ID
  static TutorialStep? getTutorialStep(String id) {
    final steps = getTutorialSteps();
    try {
      return steps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get next tutorial step
  static Future<TutorialStep?> getNextStep() async {
    final currentStep = await getCurrentStep();
    final steps = getTutorialSteps();
    
    if (currentStep < steps.length - 1) {
      return steps[currentStep + 1];
    }
    return null;
  }

  /// Get previous tutorial step
  static Future<TutorialStep?> getPreviousStep() async {
    final currentStep = await getCurrentStep();
    final steps = getTutorialSteps();
    
    if (currentStep > 0) {
      return steps[currentStep - 1];
    }
    return null;
  }

  /// Check if user should see tutorial
  static Future<bool> shouldShowTutorial() async {
    final completed = await isTutorialCompleted();
    final skipped = await isTutorialSkipped();
    return !completed && !skipped;
  }

  /// Get tutorial progress percentage
  static Future<double> getTutorialProgress() async {
    final currentStep = await getCurrentStep();
    final totalSteps = getTutorialSteps().length;
    return (currentStep / totalSteps).clamp(0.0, 1.0);
  }
}

/// Tutorial Step Model
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String action;
  final IconData icon;
  final Color color;
  final bool isInteractive;
  final TutorialAction? interactiveAction;
  final String? interactiveText;
  final String? interactiveTarget;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
    required this.color,
    required this.isInteractive,
    this.interactiveAction,
    this.interactiveText,
    this.interactiveTarget,
  });
}

/// Tutorial Action Types
enum TutorialAction {
  speak,
  tap,
  swipe,
  longPress,
}

/// Tutorial Overlay Widget
class TutorialOverlay extends StatefulWidget {
  final TutorialStep step;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;
  final VoidCallback? onComplete;
  final Widget child;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.child,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTutorialOverlay(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.step.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.step.icon,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                widget.step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.step.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.step.action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.onPrevious != null)
          _buildButton(
            text: 'Previous',
            onPressed: widget.onPrevious!,
            color: Colors.white.withOpacity(0.8),
            textColor: widget.step.color,
          ),
        if (widget.onSkip != null)
          _buildButton(
            text: 'Skip',
            onPressed: widget.onSkip!,
            color: Colors.white.withOpacity(0.3),
            textColor: Colors.white,
          ),
        if (widget.step.isInteractive)
          _buildButton(
            text: 'Try It!',
            onPressed: widget.onNext ?? () {},
            color: Colors.white,
            textColor: widget.step.color,
          )
        else if (widget.onNext != null)
          _buildButton(
            text: 'Next',
            onPressed: widget.onNext!,
            color: Colors.white,
            textColor: widget.step.color,
          )
        else if (widget.onComplete != null)
          _buildButton(
            text: 'Complete',
            onPressed: widget.onComplete!,
            color: Colors.white,
            textColor: widget.step.color,
          ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
}
