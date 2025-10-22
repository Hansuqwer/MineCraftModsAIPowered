import 'package:flutter/material.dart';
import 'dart:async';
import '../services/enhanced_voice_ai_service.dart';
import '../services/voice_personality_service.dart';
import '../services/educational_voice_service.dart';
// import '../widgets/conversational_voice_widget.dart'; // DISABLED: broken widget
import '../theme/kid_friendly_theme.dart';
import '../models/conversation.dart';

/// Simplified Enhanced Creator Screen with conversational AI
class EnhancedCreatorScreenSimple extends StatefulWidget {
  const EnhancedCreatorScreenSimple({Key? key}) : super(key: key);

  @override
  State<EnhancedCreatorScreenSimple> createState() => _EnhancedCreatorScreenSimpleState();
}

class _EnhancedCreatorScreenSimpleState extends State<EnhancedCreatorScreenSimple>
    with TickerProviderStateMixin {
  final EnhancedVoiceAIService _voiceAI = EnhancedVoiceAIService();
  final VoicePersonalityService _personalityService = VoicePersonalityService();
  final EducationalVoiceService _educationalService = EducationalVoiceService();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  bool _isInitialized = false;
  Conversation? _currentConversation;
  String _currentResponse = '';
  List<String> _achievements = [];
  
  // Debouncing for response updates
  Timer? _responseDebounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations only once
    _fadeController.forward();
    _slideController.forward();
    
    // Stop animations after initial load to prevent flickering
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeController.stop();
      }
    });
    
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideController.stop();
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      await _voiceAI.initialize();
      await _voiceAI.startConversation();
      
      setState(() {
        _isInitialized = true;
        _currentConversation = _voiceAI.currentConversation;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      _showErrorDialog('Failed to initialize voice services: $e');
    }
  }

  @override
  void dispose() {
    _responseDebounceTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onVoiceResponse(String response) {
    // Cancel previous debounce timer
    _responseDebounceTimer?.cancel();
    
    // Debounce response updates to prevent flickering
    _responseDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentResponse = response;
          
          // Award achievement for learning
          final achievement = 'Had a conversation with Crafta!';
          if (!_achievements.contains(achievement)) {
            _achievements.add(achievement);
          }
        });
      }
    });
  }

  void _onVoiceError(String error) {
    _showErrorDialog(error);
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Oops!',
          style: TextStyle(
            fontSize: KidFriendlyTheme.headingFontSize,
            fontWeight: FontWeight.bold,
            color: KidFriendlyTheme.textDark,
          ),
        ),
        content: Text(
          error,
          style: TextStyle(
            fontSize: KidFriendlyTheme.bodyFontSize,
            color: KidFriendlyTheme.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Try Again',
              style: TextStyle(
                fontSize: KidFriendlyTheme.buttonFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: KidFriendlyTheme.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  KidFriendlyTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Setting up Crafta...',
                style: TextStyle(
                  fontSize: KidFriendlyTheme.headingFontSize,
                  fontWeight: FontWeight.bold,
                  color: KidFriendlyTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KidFriendlyTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Voice interaction widget - DISABLED: widget broken
                    // ConversationalVoiceWidget(
                    //   onResponse: _onVoiceResponse,
                    //   onError: _onVoiceError,
                    //   isEnabled: true,
                    // ),

                    const SizedBox(height: 32),

                    // Response display - Optimized to prevent flickering
                    _buildResponseArea(),
                    
                    const SizedBox(height: 32),
                    
                    // Achievements
                    if (_achievements.isNotEmpty) _buildAchievements(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: KidFriendlyTheme.getRainbowGradient(),
        boxShadow: [
          BoxShadow(
            color: KidFriendlyTheme.primaryPurple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhanced Creator',
                  style: TextStyle(
                    fontSize: KidFriendlyTheme.titleFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Talk to Crafta and learn while you create!',
                  style: TextStyle(
                    fontSize: KidFriendlyTheme.bodyFontSize,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseArea() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KidFriendlyTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KidFriendlyTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.chat,
                color: KidFriendlyTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Crafta\'s Response',
                style: TextStyle(
                  fontSize: KidFriendlyTheme.headingFontSize,
                  color: KidFriendlyTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentResponse.isNotEmpty
                    ? Text(
                        _currentResponse,
                        key: ValueKey(_currentResponse),
                        style: TextStyle(
                          fontSize: KidFriendlyTheme.bodyFontSize,
                          color: KidFriendlyTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        'Start talking to see Crafta\'s response!',
                        key: const ValueKey('placeholder'),
                        style: TextStyle(
                          fontSize: KidFriendlyTheme.bodyFontSize,
                          color: KidFriendlyTheme.textMedium,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KidFriendlyTheme.primaryYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KidFriendlyTheme.primaryYellow.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: KidFriendlyTheme.primaryYellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Achievements!',
                style: TextStyle(
                  fontSize: KidFriendlyTheme.headingFontSize,
                  color: KidFriendlyTheme.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._achievements.map((achievement) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: KidFriendlyTheme.primaryYellow,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  achievement,
                  style: TextStyle(
                    fontSize: KidFriendlyTheme.bodyFontSize,
                    color: KidFriendlyTheme.textDark,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}