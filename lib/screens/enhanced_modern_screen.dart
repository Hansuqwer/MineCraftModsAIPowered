import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/enhanced_modern_theme.dart';
import '../services/enhanced_voice_ai_service.dart';
import '../services/ai_suggestion_enhanced_service.dart';
import '../services/google_cloud_service.dart';
import '../models/enhanced_creature_attributes.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

/// Enhanced Modern Screen
/// Showcases the new modern UI/UX with enhanced AI voice and suggestions
class EnhancedModernScreen extends StatefulWidget {
  const EnhancedModernScreen({super.key});

  @override
  State<EnhancedModernScreen> createState() => _EnhancedModernScreenState();
}

class _EnhancedModernScreenState extends State<EnhancedModernScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Services
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  
  // State
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentLanguage = 'en';
  VoicePersonality? _currentPersonality;
  List<ItemSuggestion> _suggestions = [];
  bool _isSignedIn = false;
  List<CloudCreation> _userCreations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: EnhancedModernTheme.animationMedium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: EnhancedModernTheme.animationMedium,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: EnhancedModernTheme.animationFast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: EnhancedModernTheme.curveEaseOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: EnhancedModernTheme.curveEaseOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: EnhancedModernTheme.curveBounceOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  Future<void> _loadUserData() async {
    _currentLanguage = await EnhancedVoiceAIService.getCurrentLanguage();
    _currentPersonality = await EnhancedVoiceAIService.getCurrentPersonality();
    _isSignedIn = await GoogleCloudService.isSignedIn();
    
    if (_isSignedIn) {
      _userCreations = await GoogleCloudService.loadUserCreations();
    }
    
    setState(() {});
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _isProcessing = false;
    });

    await _speechService.startListening(
      onResult: (result) async {
        await _handleSpeechResult(result);
      },
      onError: (error) {
        print('Speech error: $error');
      },
    );
  }

  Future<void> _handleSpeechResult(String result) async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    // Generate AI response
    final aiResponse = await EnhancedVoiceAIService.generateVoiceResponse(
      userMessage: result,
      context: 'creation',
      currentCreature: null,
      language: _currentLanguage,
    );

    // Speak the response
    await _ttsService.speak(aiResponse);

    // Generate suggestions
    final suggestions = await AISuggestionEnhancedService.generateSuggestions(
      item: EnhancedCreatureAttributes(
        baseType: 'dragon',
        customName: 'Test Dragon',
        primaryColor: Colors.red,
        secondaryColor: Colors.blue,
        accentColor: Colors.green,
        size: CreatureSize.medium,
        personality: PersonalityType.friendly,
        abilities: [],
        accessories: [],
        patterns: [],
        texture: TextureType.smooth,
        glowEffect: GlowEffect.none,
        animationStyle: CreatureAnimationStyle.natural,
        description: 'A test dragon for suggestions',
      ),
      language: _currentLanguage,
      context: 'creation',
    );

    setState(() {
      _suggestions = suggestions;
      _isProcessing = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    final result = await GoogleCloudService.signInWithGoogle();
    
    if (result.success) {
      setState(() {
        _isSignedIn = true;
      });
      await _loadUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        EnhancedModernTheme.modernSnackBar(
          message: result.message ?? 'Successfully signed in!',
          backgroundColor: EnhancedModernTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        EnhancedModernTheme.modernSnackBar(
          message: result.error ?? 'Sign in failed',
          backgroundColor: EnhancedModernTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await GoogleCloudService.signOut();
    setState(() {
      _isSignedIn = false;
      _userCreations = [];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedModernTheme.modernSnackBar(
        message: 'Successfully signed out!',
        backgroundColor: EnhancedModernTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedModernTheme.backgroundLight,
      appBar: EnhancedModernTheme.modernAppBar(
        title: 'Enhanced Crafta',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: EnhancedModernTheme.spacingLarge),
                _buildVoiceSection(),
                const SizedBox(height: EnhancedModernTheme.spacingLarge),
                _buildSuggestionsSection(),
                const SizedBox(height: EnhancedModernTheme.spacingLarge),
                _buildCloudSection(),
                const SizedBox(height: EnhancedModernTheme.spacingLarge),
                _buildPersonalitySection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: EnhancedModernTheme.modernFAB(
        onPressed: _startListening,
        child: _isListening
            ? const Icon(Icons.mic)
            : const Icon(Icons.mic_none),
        tooltip: 'Start Voice Command',
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: EnhancedModernTheme.modernCard(
          shadows: EnhancedModernTheme.mediumShadow,
        ),
        padding: const EdgeInsets.all(EnhancedModernTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: EnhancedModernTheme.primaryBlue,
                ),
                const SizedBox(width: EnhancedModernTheme.spacingMedium),
                Expanded(
                  child: Text(
                    'Welcome to Enhanced Crafta!',
                    style: EnhancedModernTheme.heading2.copyWith(
                      color: EnhancedModernTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
            Text(
              'Experience the future of AI-powered creativity with enhanced voice interactions, intelligent suggestions, and cloud storage.',
              style: EnhancedModernTheme.bodyLarge.copyWith(
                color: EnhancedModernTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Container(
      decoration: EnhancedModernTheme.modernCard(
        shadows: EnhancedModernTheme.lightShadow,
      ),
      padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced Voice AI',
            style: EnhancedModernTheme.heading3.copyWith(
              color: EnhancedModernTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: EnhancedModernTheme.spacingMedium),
          if (_currentPersonality != null) ...[
            Row(
              children: [
                Text(_currentPersonality!.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: EnhancedModernTheme.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPersonality!.name,
                        style: EnhancedModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _currentPersonality!.description,
                        style: EnhancedModernTheme.bodyMedium.copyWith(
                          color: EnhancedModernTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isListening ? null : _startListening,
                  icon: _isListening
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mic),
                  label: Text(_isListening ? 'Listening...' : 'Start Voice Command'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnhancedModernTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnhancedModernTheme.spacingMedium,
                      vertical: EnhancedModernTheme.spacingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: EnhancedModernTheme.spacingSmall),
              IconButton(
                onPressed: _showPersonalityDialog,
                icon: const Icon(Icons.person),
                tooltip: 'Change Personality',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: EnhancedModernTheme.modernCard(
        shadows: EnhancedModernTheme.lightShadow,
      ),
      padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Suggestions',
            style: EnhancedModernTheme.heading3.copyWith(
              color: EnhancedModernTheme.accentPurple,
            ),
          ),
          const SizedBox(height: EnhancedModernTheme.spacingMedium),
          ..._suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ItemSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: EnhancedModernTheme.spacingSmall),
      decoration: EnhancedModernTheme.modernCard(
        backgroundColor: suggestion.priority == SuggestionPriority.high
            ? EnhancedModernTheme.primaryBlueLight.withOpacity(0.1)
            : null,
        shadows: EnhancedModernTheme.lightShadow,
      ),
      padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSuggestionIcon(suggestion.type),
                color: _getSuggestionColor(suggestion.type),
                size: 20,
              ),
              const SizedBox(width: EnhancedModernTheme.spacingSmall),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: EnhancedModernTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: EnhancedModernTheme.spacingSmall,
                  vertical: EnhancedModernTheme.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(suggestion.priority),
                  borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusSmall),
                ),
                child: Text(
                  suggestion.priority.name.toUpperCase(),
                  style: EnhancedModernTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnhancedModernTheme.spacingSmall),
          Text(
            suggestion.description,
            style: EnhancedModernTheme.bodyMedium.copyWith(
              color: EnhancedModernTheme.textSecondary,
            ),
          ),
          const SizedBox(height: EnhancedModernTheme.spacingSmall),
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.reasoning,
                  style: EnhancedModernTheme.bodySmall.copyWith(
                    color: EnhancedModernTheme.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: EnhancedModernTheme.spacingSmall),
              ElevatedButton(
                onPressed: () => _applySuggestion(suggestion),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSuggestionColor(suggestion.type),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnhancedModernTheme.spacingMedium,
                    vertical: EnhancedModernTheme.spacingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusSmall),
                  ),
                ),
                child: Text(suggestion.action),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSection() {
    return Container(
      decoration: EnhancedModernTheme.modernCard(
        shadows: EnhancedModernTheme.lightShadow,
      ),
      padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud,
                color: EnhancedModernTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: EnhancedModernTheme.spacingSmall),
              Text(
                'Cloud Storage',
                style: EnhancedModernTheme.heading3.copyWith(
                  color: EnhancedModernTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: EnhancedModernTheme.spacingMedium),
          if (_isSignedIn) ...[
            Text(
              'Signed in as: ${GoogleCloudService.getCurrentUser()?.email ?? 'Unknown'}',
              style: EnhancedModernTheme.bodyMedium.copyWith(
                color: EnhancedModernTheme.textSecondary,
              ),
            ),
            const SizedBox(height: EnhancedModernTheme.spacingSmall),
            Text(
              'Your Creations: ${_userCreations.length}',
              style: EnhancedModernTheme.bodyMedium.copyWith(
                color: EnhancedModernTheme.textSecondary,
              ),
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _syncWithCloud,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync with Cloud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EnhancedModernTheme.successGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: EnhancedModernTheme.spacingSmall),
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnhancedModernTheme.errorRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Sign in to save your creations to the cloud and access them from any device.',
              style: EnhancedModernTheme.bodyMedium.copyWith(
                color: EnhancedModernTheme.textSecondary,
              ),
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: EnhancedModernTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalitySection() {
    return Container(
      decoration: EnhancedModernTheme.modernCard(
        shadows: EnhancedModernTheme.lightShadow,
      ),
      padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice Personality',
            style: EnhancedModernTheme.heading3.copyWith(
              color: EnhancedModernTheme.accentPurple,
            ),
          ),
          const SizedBox(height: EnhancedModernTheme.spacingMedium),
          Text(
            'Choose how Crafta talks to you. Each personality has a unique style and approach.',
            style: EnhancedModernTheme.bodyMedium.copyWith(
              color: EnhancedModernTheme.textSecondary,
            ),
          ),
          const SizedBox(height: EnhancedModernTheme.spacingMedium),
          ElevatedButton.icon(
            onPressed: _showPersonalityDialog,
            icon: const Icon(Icons.person),
            label: const Text('Change Personality'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EnhancedModernTheme.accentPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSuggestionIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.color:
        return Icons.palette;
      case SuggestionType.size:
        return Icons.aspect_ratio;
      case SuggestionType.ability:
        return Icons.auto_awesome;
      case SuggestionType.accessory:
        return Icons.style;
      case SuggestionType.material:
        return Icons.diamond;
      case SuggestionType.behavior:
        return Icons.psychology;
    }
  }

  Color _getSuggestionColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.color:
        return EnhancedModernTheme.accentPurple;
      case SuggestionType.size:
        return EnhancedModernTheme.primaryBlue;
      case SuggestionType.ability:
        return EnhancedModernTheme.successGreen;
      case SuggestionType.accessory:
        return EnhancedModernTheme.warningOrange;
      case SuggestionType.material:
        return EnhancedModernTheme.errorRed;
      case SuggestionType.behavior:
        return EnhancedModernTheme.accentPurpleLight;
    }
  }

  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return EnhancedModernTheme.textSecondary;
      case SuggestionPriority.medium:
        return EnhancedModernTheme.warningOrange;
      case SuggestionPriority.high:
        return EnhancedModernTheme.errorRed;
    }
  }

  void _applySuggestion(ItemSuggestion suggestion) {
    // Apply the suggestion logic here
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedModernTheme.modernSnackBar(
        message: 'Applied suggestion: ${suggestion.title}',
        backgroundColor: EnhancedModernTheme.successGreen,
      ),
    );
  }

  Future<void> _syncWithCloud() async {
    final result = await GoogleCloudService.syncWithCloud();
    
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedModernTheme.modernSnackBar(
        message: result.success 
            ? (result.message ?? 'Sync completed!')
            : (result.error ?? 'Sync failed'),
        backgroundColor: result.success 
            ? EnhancedModernTheme.successGreen 
            : EnhancedModernTheme.errorRed,
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedModernTheme.modernDialog(
        title: 'Settings',
        content: 'Configure your Crafta experience',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPersonalityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Voice Personality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('👩‍🏫', style: TextStyle(fontSize: 24)),
              title: const Text('Friendly Teacher'),
              subtitle: const Text('Warm, encouraging, and educational'),
              onTap: () async {
                await EnhancedVoiceAIService.setPersonality('friendly_teacher');
                setState(() {
                  _currentPersonality = const VoicePersonality(
                    name: 'Friendly Teacher',
                    description: 'Warm, encouraging, and educational',
                    traits: ['encouraging', 'patient', 'educational'],
                    responseStyle: 'warm and supportive',
                    emoji: '👩‍🏫',
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🎉', style: TextStyle(fontSize: 24)),
              title: const Text('Playful Friend'),
              subtitle: const Text('Fun, energetic, and creative'),
              onTap: () async {
                await EnhancedVoiceAIService.setPersonality('playful_friend');
                setState(() {
                  _currentPersonality = const VoicePersonality(
                    name: 'Playful Friend',
                    description: 'Fun, energetic, and creative',
                    traits: ['energetic', 'creative', 'humorous'],
                    responseStyle: 'fun and exciting',
                    emoji: '🎉',
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🧙‍♂️', style: TextStyle(fontSize: 24)),
              title: const Text('Wise Mentor'),
              subtitle: const Text('Thoughtful, knowledgeable, and guiding'),
              onTap: () async {
                await EnhancedVoiceAIService.setPersonality('wise_mentor');
                setState(() {
                  _currentPersonality = const VoicePersonality(
                    name: 'Wise Mentor',
                    description: 'Thoughtful, knowledgeable, and guiding',
                    traits: ['thoughtful', 'knowledgeable', 'guiding'],
                    responseStyle: 'wise and thoughtful',
                    emoji: '🧙‍♂️',
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🏔️', style: TextStyle(fontSize: 24)),
              title: const Text('Adventurous Guide'),
              subtitle: const Text('Bold, exciting, and inspiring'),
              onTap: () async {
                await EnhancedVoiceAIService.setPersonality('adventurous_guide');
                setState(() {
                  _currentPersonality = const VoicePersonality(
                    name: 'Adventurous Guide',
                    description: 'Bold, exciting, and inspiring',
                    traits: ['bold', 'exciting', 'inspiring'],
                    responseStyle: 'bold and adventurous',
                    emoji: '🏔️',
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
