import 'package:flutter/material.dart';
import '../services/enhanced_voice_ai_service.dart';
import '../services/voice_personality_service.dart';
import '../services/educational_voice_service.dart';
import '../widgets/conversational_voice_widget.dart';
import '../widgets/minecraft_3d_preview.dart';
import '../theme/kid_friendly_theme.dart';
import '../models/conversation.dart';

/// Enhanced creator screen with conversational AI and educational features
class EnhancedCreatorScreen extends StatefulWidget {
  const EnhancedCreatorScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedCreatorScreen> createState() => _EnhancedCreatorScreenState();
}

class _EnhancedCreatorScreenState extends State<EnhancedCreatorScreen>
    with TickerProviderStateMixin {
  final EnhancedVoiceAIService _voiceAI = EnhancedVoiceAIService();
  final VoicePersonalityService _personalityService = VoicePersonalityService();
  final EducationalVoiceService _educationalService = EducationalVoiceService();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _sparkleController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sparkleAnimation;

  // State
  bool _isInitialized = false;
  Conversation? _currentConversation;
  String _currentResponse = '';
  bool _showEducationalContentFlag = false;
  String _currentEducationalTopic = 'creativity';
  List<String> _achievements = [];

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
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
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
    _fadeController.dispose();
    _slideController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _onVoiceResponse(String response) {
    setState(() {
      _currentResponse = response;
    });

    // Start sparkle animation
    _sparkleController.forward().then((_) {
      _sparkleController.reverse();
    });

    // Check for educational opportunities
    _checkForEducationalContent(response);
  }

  void _onVoiceError(String error) {
    _showErrorDialog(error);
  }

  void _checkForEducationalContent(String response) {
    // Simple keyword detection for educational content
    final lowerResponse = response.toLowerCase();
    
    if (lowerResponse.contains('dragon') || lowerResponse.contains('animal')) {
      _showEducationalContentMethod('animals');
    } else if (lowerResponse.contains('color') || lowerResponse.contains('rainbow')) {
      _showEducationalContentMethod('colors');
    } else if (lowerResponse.contains('create') || lowerResponse.contains('imagine')) {
      _showEducationalContentMethod('creativity');
    } else if (lowerResponse.contains('friend') || lowerResponse.contains('together')) {
      _showEducationalContentMethod('friendship');
    } else if (lowerResponse.contains('nature') || lowerResponse.contains('tree')) {
      _showEducationalContentMethod('nature');
    }
  }

  void _showEducationalContentMethod(String topic) {
    setState(() {
      _showEducationalContentFlag = true;
      _currentEducationalTopic = topic;
    });

    // Award achievement
    final achievement = 'Learned about $topic';
    if (!_achievements.contains(achievement)) {
      setState(() {
        _achievements.add(achievement);
      });
    }
  }

  void _hideEducationalContent() {
    setState(() {
      _showEducationalContentFlag = false;
    });
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
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
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
                            // Voice interaction widget
                            ConversationalVoiceWidget(
                              onResponse: _onVoiceResponse,
                              onError: _onVoiceError,
                              isEnabled: true,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // 3D Preview area
                            _buildPreviewArea(),
                            
                            const SizedBox(height: 32),
                            
                            // Educational content
                            if (_showEducationalContentFlag) _buildEducationalContent(),
                            
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
          },
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
                  style: KidFriendlyTheme.textStyles['title'].copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Talk to Crafta and learn while you create!',
                  style: KidFriendlyTheme.textStyles['body'].copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Settings button
          IconButton(
            onPressed: () => _showSettings(),
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: KidFriendlyTheme.primaryColors['blue']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KidFriendlyTheme.primaryColors['blue']!.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Preview header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KidFriendlyTheme.primaryColors['blue']!.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  color: KidFriendlyTheme.primaryColors['blue']!,
                ),
                const SizedBox(width: 8),
                Text(
                  '3D Preview',
                  style: KidFriendlyTheme.textStyles['heading'].copyWith(
                    color: KidFriendlyTheme.primaryColors['blue']!,
                  ),
                ),
              ],
            ),
          ),
          
          // Preview content
          Expanded(
            child: Center(
              child: _currentResponse.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 64,
                          color: KidFriendlyTheme.primaryColors['purple']!,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Creating your vision...',
                          style: KidFriendlyTheme.textStyles['body'].copyWith(
                            color: KidFriendlyTheme.primaryColors['purple']!,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Start talking to see your creation!',
                      style: KidFriendlyTheme.textStyles['body'].copyWith(
                        color: KidFriendlyTheme.primaryColors['blue']!.withOpacity(0.7),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalContent() {
    final content = _educationalService.getEducationalContent(_currentEducationalTopic);
    if (content == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KidFriendlyTheme.primaryColors['green']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KidFriendlyTheme.primaryColors['green']!.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: KidFriendlyTheme.primaryColors['green']!,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Did You Know?',
                style: KidFriendlyTheme.textStyles['heading'].copyWith(
                  color: KidFriendlyTheme.primaryColors['green']!,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _hideEducationalContent,
                icon: Icon(
                  Icons.close,
                  color: KidFriendlyTheme.primaryColors['green']!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.facts.first,
            style: KidFriendlyTheme.textStyles['body'].copyWith(
              color: KidFriendlyTheme.primaryColors['green']!,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.questions.first,
            style: KidFriendlyTheme.textStyles['body'].copyWith(
              color: KidFriendlyTheme.primaryColors['green']!,
              fontWeight: FontWeight.bold,
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
        color: KidFriendlyTheme.primaryColors['yellow']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KidFriendlyTheme.primaryColors['yellow']!.withOpacity(0.3),
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
                color: KidFriendlyTheme.primaryColors['yellow']!,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Achievements!',
                style: KidFriendlyTheme.textStyles['heading'].copyWith(
                  color: KidFriendlyTheme.primaryColors['yellow']!,
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
                  color: KidFriendlyTheme.primaryColors['yellow']!,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  achievement,
                  style: KidFriendlyTheme.textStyles['body'].copyWith(
                    color: KidFriendlyTheme.primaryColors['yellow']!,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Settings',
          style: KidFriendlyTheme.textStyles['heading'],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Crafta\'s Personality:',
              style: KidFriendlyTheme.textStyles['body'],
            ),
            const SizedBox(height: 16),
            ...VoicePersonality.values.map((personality) => ListTile(
              leading: Text(
                _personalityService.getPersonalityEmoji(personality),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                _personalityService._getPersonalityName(personality),
                style: KidFriendlyTheme.textStyles['body'],
              ),
              subtitle: Text(
                _personalityService.getPersonalityDescription(personality),
                style: KidFriendlyTheme.textStyles['body'].copyWith(
                  fontSize: 12,
                ),
              ),
              onTap: () {
                _voiceAI.changePersonality(personality);
                Navigator.of(context).pop();
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: KidFriendlyTheme.textStyles['button'],
            ),
          ),
        ],
      ),
    );
  }
}