import 'package:flutter/material.dart';
import '../services/kid_voice_service.dart';
// import '../services/simple_conversational_ai.dart';
import '../widgets/kid_voice_button.dart';
import '../widgets/kid_friendly_components.dart';
import '../theme/kid_friendly_theme.dart';
import '../models/enhanced_creature_attributes.dart';
import '../widgets/simple_3d_preview.dart';

/// 🎮 Kid-Friendly Screen
/// Optimized for children ages 4-10 with enhanced voice interaction
class KidFriendlyScreen extends StatefulWidget {
  const KidFriendlyScreen({super.key});

  @override
  State<KidFriendlyScreen> createState() => _KidFriendlyScreenState();
}

class _KidFriendlyScreenState extends State<KidFriendlyScreen>
    with TickerProviderStateMixin {
  final KidVoiceService _kidVoiceService = KidVoiceService();
  // final SimpleConversationalAI _conversationalAI = SimpleConversationalAI();
  final TextEditingController _textController = TextEditingController();
  
  bool _isLoading = false;
  bool _isListening = false;
  String _currentPrompt = '';
  String _lastVoiceResult = '';
  String _encouragementMessage = '';
  
  // Current item being created
  EnhancedCreatureAttributes? _currentAttributes;
  String _currentItemName = '';
  
  // Animations
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
    _setupPrompts();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _sparkleController = AnimationController(
      duration: Duration(seconds: 2),
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

  Future<void> _initializeVoiceService() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _kidVoiceService.initialize();
      if (success) {
        print('✅ Kid voice service initialized');
      } else {
        print('❌ Kid voice service failed to initialize');
      }
    } catch (e) {
      print('❌ Error initializing kid voice service: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setupPrompts() {
    final prompts = _kidVoiceService.getKidPrompts();
    _currentPrompt = prompts[0];
  }

  Future<void> _handleVoiceResult(String result) async {
    setState(() {
      _lastVoiceResult = result;
      _isListening = false;
    });

    // Parse the voice input with AI (PHASE 0.1 improvement)
    try {
      final attributes = await _kidVoiceService.parseKidVoiceWithAI(result);

    _currentItemName = _generateItemName(attributes);

    // Show encouragement
    setState(() {
      _encouragementMessage = 'Great! Let me show you what I created!';
    });

    // Wait for encouragement to be spoken
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    // PHASE E: Navigate to preview approval screen instead of showing inline
    Navigator.pushNamed(
      context,
      '/creature-preview-approval',
      arguments: {
        'creatureAttributes': attributes,
        'creatureName': _currentItemName,
      },
    );

    } catch (e) {
      print('❌ Error parsing voice: $e');
      _handleEncouragement('Oops! Let me try again.');
    }
  }

  void _handleEncouragement(String message) {
    setState(() {
      _encouragementMessage = message;
    });
    
    // Clear encouragement after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _encouragementMessage = '';
        });
      }
    });
  }

  CreatureSize _getSizeFromString(String size) {
    switch (size.toLowerCase()) {
      case 'big':
      case 'huge':
        return CreatureSize.large;
      case 'small':
      case 'tiny':
        return CreatureSize.small;
      default:
        return CreatureSize.medium;
    }
  }

  PersonalityType _getPersonalityFromString(String personality) {
    switch (personality.toLowerCase()) {
      case 'friendly':
        return PersonalityType.friendly;
      case 'brave':
        return PersonalityType.brave;
      case 'curious':
        return PersonalityType.curious;
      default:
        return PersonalityType.friendly;
    }
  }

  List<SpecialAbility> _getAbilitiesFromEffects(List<String> effects) {
    final abilities = <SpecialAbility>[];
    
    for (final effect in effects) {
      switch (effect.toLowerCase()) {
        case 'flying':
          abilities.add(SpecialAbility.flying);
          break;
        case 'glowing':
        case 'sparkly':
          abilities.add(SpecialAbility.magic);
          break;
        case 'fire':
          abilities.add(SpecialAbility.fireBreath);
          break;
        case 'ice':
          abilities.add(SpecialAbility.iceBreath);
          break;
        case 'super':
        case 'mega':
          abilities.add(SpecialAbility.superSpeed);
          break;
      }
    }
    
    return abilities;
  }

  String _generateItemName(Map<String, dynamic> attributes) {
    final baseType = attributes['baseType'] ?? 'creature';
    final color = attributes['primaryColor'];
    final effects = attributes['effects'] ?? [];
    
    String name = baseType;
    
    if (color != null) {
      name = '${_getColorName(color)} $name';
    }
    
    if (effects.isNotEmpty) {
      name = '${effects.first} $name';
    }
    
    return name.replaceAll('_', ' ').split(' ').map((word) => 
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.amber) return 'Gold';
    return 'Blue';
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🎮 How to Use Crafta',
          style: TextStyle(
            fontSize: KidFriendlyTheme.headingFontSize,
            fontWeight: FontWeight.bold,
            color: KidFriendlyTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Tap the big microphone button',
              style: TextStyle(fontSize: KidFriendlyTheme.bodyFontSize),
            ),
            SizedBox(height: KidFriendlyTheme.smallSpacing),
            Text(
              '2. Say what you want to create',
              style: TextStyle(fontSize: KidFriendlyTheme.bodyFontSize),
            ),
            SizedBox(height: KidFriendlyTheme.smallSpacing),
            Text(
              '3. Watch your creation come to life!',
              style: TextStyle(fontSize: KidFriendlyTheme.bodyFontSize),
            ),
            SizedBox(height: KidFriendlyTheme.mediumSpacing),
            Text(
              'Try saying:',
              style: TextStyle(
                fontSize: KidFriendlyTheme.bodyFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: KidFriendlyTheme.smallSpacing),
            Text(
              '• "Make me a dragon!"',
              style: TextStyle(fontSize: KidFriendlyTheme.captionFontSize),
            ),
            Text(
              '• "I want a blue sword!"',
              style: TextStyle(fontSize: KidFriendlyTheme.captionFontSize),
            ),
            Text(
              '• "Create a rainbow cat!"',
              style: TextStyle(fontSize: KidFriendlyTheme.captionFontSize),
            ),
          ],
        ),
        actions: [
          KidFriendlyButton(
            text: 'Got it!',
            onPressed: () => Navigator.pop(context),
            color: KidFriendlyTheme.primaryGreen,
            width: 120,
            height: 50,
          ),
        ],
      ),
    );
  }

  void _exportToMinecraft() {
    // Show export dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🎮 Export to Minecraft',
          style: TextStyle(
            fontSize: KidFriendlyTheme.headingFontSize,
            fontWeight: FontWeight.bold,
            color: KidFriendlyTheme.textDark,
          ),
        ),
        content: Text(
          'Your $_currentItemName will be exported to Minecraft!',
          style: TextStyle(fontSize: KidFriendlyTheme.bodyFontSize),
        ),
        actions: [
          KidFriendlyButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            color: KidFriendlyTheme.primaryRed,
            width: 100,
            height: 50,
          ),
          KidFriendlyButton(
            text: 'Export!',
            onPressed: () {
              Navigator.pop(context);
              _showExportSuccess();
            },
            color: KidFriendlyTheme.primaryGreen,
            width: 100,
            height: 50,
          ),
        ],
      ),
    );
  }

  void _createAnother() {
    setState(() {
      _currentAttributes = null;
      _currentItemName = '';
      _lastVoiceResult = '';
      _encouragementMessage = '';
    });
    
    // Show encouragement
    _handleEncouragement('Let\'s create something new!');
  }

  void _showExportSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🎉 Success!',
          style: TextStyle(
            fontSize: KidFriendlyTheme.headingFontSize,
            fontWeight: FontWeight.bold,
            color: KidFriendlyTheme.primaryGreen,
          ),
        ),
        content: Text(
          'Your $_currentItemName has been exported to Minecraft!',
          style: TextStyle(fontSize: KidFriendlyTheme.bodyFontSize),
        ),
        actions: [
          KidFriendlyButton(
            text: 'Awesome!',
            onPressed: () => Navigator.pop(context),
            color: KidFriendlyTheme.primaryGreen,
            width: 120,
            height: 50,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidFriendlyTheme.backgroundBlue,
      appBar: AppBar(
        title: Text(
          '🎮 Crafta for Kids',
          style: TextStyle(
            fontSize: KidFriendlyTheme.titleFontSize,
            fontWeight: FontWeight.bold,
            color: KidFriendlyTheme.textWhite,
          ),
        ),
        backgroundColor: KidFriendlyTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Help button
          KidFriendlyIconButton(
            icon: Icons.help_outline,
            onPressed: () => _showHelpDialog(),
            color: KidFriendlyTheme.primaryYellow,
            size: KidFriendlyTheme.largeIconSize,
          ),
          SizedBox(width: KidFriendlyTheme.mediumSpacing),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KidFriendlyProgressIndicator(
                    progress: 0.7,
                    color: KidFriendlyTheme.primaryBlue,
                    message: 'Setting up voice for you...',
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(KidFriendlyTheme.largeSpacing),
              child: Column(
                children: [
                  // Welcome message
                  KidFriendlyCard(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(KidFriendlyTheme.largeSpacing),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: KidFriendlyTheme.getOceanGradient(),
                        borderRadius: BorderRadius.circular(KidFriendlyTheme.largeRadius),
                        boxShadow: KidFriendlyTheme.getButtonShadow(KidFriendlyTheme.primaryBlue),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👋 Hi there!',
                            style: TextStyle(
                              fontSize: KidFriendlyTheme.titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: KidFriendlyTheme.textWhite,
                            ),
                          ),
                          SizedBox(height: KidFriendlyTheme.mediumSpacing),
                          Text(
                            'Just talk to me and I\'ll create anything you want!',
                            style: TextStyle(
                              fontSize: KidFriendlyTheme.bodyFontSize,
                              color: KidFriendlyTheme.textWhite,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: KidFriendlyTheme.hugeSpacing),
                  
                  // Voice button
                  KidVoiceButton(
                    voiceService: _kidVoiceService,
                    onVoiceResult: _handleVoiceResult,
                    onEncouragement: _handleEncouragement,
                    isEnabled: !_isLoading,
                  ),
                  
                  SizedBox(height: KidFriendlyTheme.largeSpacing),
                  
                  // Conversational AI Widget (temporarily disabled)
                  // ConversationalVoiceWidget(
                  //   aiService: _conversationalAI,
                  //   onItemReady: _handleItemReady,
                  //   onEncouragement: _handleConversationalResponse,
                  // ),
                  
                  SizedBox(height: KidFriendlyTheme.largeSpacing),
                  
                  // Current prompt
                  if (_currentPrompt.isNotEmpty)
                    KidFriendlyCard(
                      color: KidFriendlyTheme.backgroundLight,
                      padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: KidFriendlyTheme.getSparkleGradient(),
                          borderRadius: BorderRadius.circular(KidFriendlyTheme.mediumRadius),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                          child: Text(
                            _currentPrompt,
                            style: TextStyle(
                              fontSize: KidFriendlyTheme.bodyFontSize,
                              color: KidFriendlyTheme.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  
                  SizedBox(height: KidFriendlyTheme.largeSpacing),
                  
                  // Encouragement message
                  if (_encouragementMessage.isNotEmpty)
                    AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.9 + (_sparkleAnimation.value * 0.1),
                          child: KidFriendlyCard(
                            color: Colors.transparent,
                            padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: KidFriendlyTheme.getRainbowGradient(),
                                borderRadius: BorderRadius.circular(KidFriendlyTheme.mediumRadius),
                                boxShadow: KidFriendlyTheme.getButtonShadow(KidFriendlyTheme.primaryGreen),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: KidFriendlyTheme.textWhite,
                                      size: KidFriendlyTheme.largeIconSize,
                                    ),
                                    SizedBox(width: KidFriendlyTheme.mediumSpacing),
                                    Flexible(
                                      child: Text(
                                        _encouragementMessage,
                                        style: TextStyle(
                                          fontSize: KidFriendlyTheme.bodyFontSize,
                                          color: KidFriendlyTheme.textWhite,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  SizedBox(height: KidFriendlyTheme.hugeSpacing),
                  
                  // Last voice result
                  if (_lastVoiceResult.isNotEmpty)
                    KidFriendlyCard(
                      color: KidFriendlyTheme.backgroundLight,
                      padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                      child: Column(
                        children: [
                          Text(
                            'You said:',
                            style: TextStyle(
                              fontSize: KidFriendlyTheme.bodyFontSize,
                              fontWeight: FontWeight.bold,
                              color: KidFriendlyTheme.textDark,
                            ),
                          ),
                          SizedBox(height: KidFriendlyTheme.smallSpacing),
                          Container(
                            padding: EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
                            decoration: BoxDecoration(
                              gradient: KidFriendlyTheme.getOceanGradient(),
                              borderRadius: BorderRadius.circular(KidFriendlyTheme.mediumRadius),
                            ),
                            child: Text(
                              '"$_lastVoiceResult"',
                              style: TextStyle(
                                fontSize: KidFriendlyTheme.bodyFontSize,
                                color: KidFriendlyTheme.textWhite,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
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

  /// Handle conversational AI responses
  void _handleConversationalResponse(String message) {
    setState(() {
      _encouragementMessage = message;
    });
  }

  /// Handle when item is ready from conversational AI
  void _handleItemReady(String itemName, Map<String, dynamic> attributes) {
    setState(() {
      _currentItemName = itemName;
      _currentAttributes = EnhancedCreatureAttributes(
        baseType: itemName,
        primaryColor: (attributes['color'] as Color?) ?? Colors.blue,
        secondaryColor: Colors.white,
        accentColor: Colors.yellow,
        size: _getSizeFromString(attributes['size']?.toString() ?? 'medium'),
        personality: _getPersonalityFromString(attributes['personality']?.toString() ?? 'friendly'),
        abilities: _getAbilitiesFromEffects((attributes['abilities'] as List?)?.cast<String>() ?? []),
        accessories: [],
        patterns: [Pattern.none],
        texture: TextureType.smooth,
        glowEffect: GlowEffect.none,
        animationStyle: CreatureAnimationStyle.natural,
        customName: itemName,
        description: 'AI Generated Item',
      );
    });
  }
}
