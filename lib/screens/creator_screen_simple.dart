import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/enhanced_ai_service.dart';
import '../services/enhanced_speech_service.dart';
import '../services/enhanced_tts_service.dart';
import '../services/conversation_context_service.dart';
import '../services/app_localizations.dart';
import '../services/achievement_service.dart';
import '../services/enhanced_item_creation_service.dart';
import '../models/conversation.dart';
import '../models/enhanced_creature_attributes.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';
import '../widgets/voice_feedback_widget.dart';
import 'advanced_customization_screen.dart';

/// Minecraft-inspired Creator Screen - Looks like a crafting table!
/// Now supports creating all item types: creatures, weapons, armor, furniture, tools, decorations, vehicles
class CreatorScreenSimple extends StatefulWidget {
  final ItemType? itemType;
  final MaterialType? material;

  const CreatorScreenSimple({
    super.key,
    this.itemType,
    this.material,
  });

  @override
  State<CreatorScreenSimple> createState() => _CreatorScreenSimpleState();
}

class _CreatorScreenSimpleState extends State<CreatorScreenSimple> with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  final EnhancedSpeechService _speechService = EnhancedSpeechService();
  final EnhancedTTSService _ttsService = EnhancedTTSService();
  final ConversationContextService _contextService = ConversationContextService();
  final TextEditingController _textController = TextEditingController();

  String _recognizedText = '';
  String _partialText = '';
  double _soundLevel = 0.0;
  bool _isListening = false;
  bool _isProcessing = false;
  Conversation _conversation = Conversation(messages: []);
  EnhancedCreatureAttributes? _currentCreature;
  Map<String, dynamic>? _currentItem; // For non-creature items
  late ItemType _selectedItemType; // Current item type being created

  // Animations
  late AnimationController _sendButtonController;
  late AnimationController _pulseController;
  late Animation<double> _sendButtonAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedItemType = widget.itemType ?? ItemType.creature; // Default to creature for backward compatibility
    _initializeServices();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );

    // Pulse animation for listening state (like redstone)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
    await _contextService.initialize();

    // Set up real-time callbacks
    _speechService.onSoundLevelChange = (level) {
      if (mounted) {
        setState(() => _soundLevel = level);
      }
    };

    _speechService.onPartialResult = (partial) {
      if (mounted) {
        setState(() => _partialText = partial);
      }
    };

    _speechService.onListeningStateChange = (listening) {
      if (mounted && _isListening != listening) {
        setState(() => _isListening = listening);
        if (listening) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    };

    // Play warm welcome after a brief delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _ttsService.playEncouragement();
      }
    });
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _partialText = '';
      _soundLevel = 0.0;
    });

    final result = await _speechService.listen();

    setState(() {
      _isListening = false;
      _partialText = '';
    });

    if (result != null && result.isNotEmpty) {
      setState(() => _recognizedText = result);
      await _processTextInput(result);
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await _speechService.stopListening();
  }

  Future<void> _processTextInput(String text) async {
    if (text.trim().isEmpty) return;

    _sendButtonController.forward().then((_) => _sendButtonController.reverse());

    setState(() {
      _isProcessing = true;
      _textController.clear();
    });

    try {
      // Add to conversation context
      await _contextService.addUserMessage(text);
      _conversation = _conversation.addMessage(text, true);

      // Handle different item types
      if (_selectedItemType == ItemType.creature) {
        await _processCreatureCreation(text);
      } else {
        await _processItemCreation(text);
      }

      setState(() {
        _isProcessing = false;
        _recognizedText = '';
      });

    } catch (e) {
      print('Error processing text: $e');
      setState(() => _isProcessing = false);
      await _ttsService.speak('Oops! Let\'s try that again!');
    }
  }

  /// Process creature creation (original logic)
  Future<void> _processCreatureCreation(String text) async {
    final enhancedAttributes = await EnhancedAIService.parseEnhancedCreatureRequest(text);

    // Update context with current creature
    await _contextService.setCurrentCreature(enhancedAttributes.customName);

    final responseText = 'I created ${enhancedAttributes.customName}! ${enhancedAttributes.fullDescription}';

    setState(() {
      _currentCreature = enhancedAttributes;
      _conversation = _conversation.addMessage(responseText, false);
    });

    // Add Crafta's response to context
    await _contextService.addCraftaResponse(
      responseText,
      metadata: {'creatureCreated': true},
    );

    // Track achievement progress
    await AchievementService.updateProgress(RequirementType.creaturesCreated, 1);

    // Track specific creature types
    if (enhancedAttributes.baseType.toLowerCase().contains('dragon')) {
      await AchievementService.updateProgress(RequirementType.dragonsCreated, 1);
    }

    // Track colors used
    final colorsUsed = _extractColorsFromAttributes(enhancedAttributes);
    for (final color in colorsUsed) {
      await AchievementService.updateStats('color_$color', 1);
    }

    await _ttsService.speak(responseText);
    await Future.delayed(const Duration(milliseconds: 500));
    await _ttsService.playEncouragement();

    // Navigate to 3D viewer to show exactly how it will look in Minecraft
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/minecraft-3d-viewer',
          arguments: {
            'creatureAttributes': enhancedAttributes.toMap(),
            'creatureName': enhancedAttributes.customName,
          },
        );
      }
    });
  }

  /// Process item creation (weapons, armor, furniture, tools, etc.)
  Future<void> _processItemCreation(String text) async {
    // Use AI to generate item from user's description
    final prompt = EnhancedItemCreationService.generatePromptForItemType(
      itemType: _selectedItemType,
      userInput: text,
      material: widget.material,
    );

    // Get AI response using the specialized prompt
    // We send the full prompt directly to get structured JSON responses
    final aiResponse = await _aiService.processPrompt(prompt);

    // Parse response into item attributes
    final itemAttributes = EnhancedItemCreationService.parseItemResponse(
      aiResponse,
      _selectedItemType,
    );

    final itemName = itemAttributes['customName'] ?? 'My ${_selectedItemType.displayName}';
    final description = itemAttributes['description'] ?? 'A cool ${_selectedItemType.displayName}!';

    final responseText = 'I created $itemName! $description';

    setState(() {
      _currentItem = itemAttributes;
      _conversation = _conversation.addMessage(responseText, false);
    });

    // Add Crafta's response to context
    await _contextService.addCraftaResponse(
      responseText,
      metadata: {'itemCreated': true, 'itemType': _selectedItemType.toString()},
    );

    await _ttsService.speak(responseText);
    await Future.delayed(const Duration(milliseconds: 500));
    await _ttsService.playEncouragement();

    // Navigate to 3D viewer to show item
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/minecraft-3d-viewer',
          arguments: {
            'creatureAttributes': itemAttributes,
            'creatureName': itemName,
          },
        );
      }
    });
  }

  Future<void> _openAdvancedCustomization() async {
    if (_currentCreature == null) return;

    final result = await Navigator.push<EnhancedCreatureAttributes>(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedCustomizationScreen(
          initialAttributes: _currentCreature!,
          onAttributesChanged: (attributes) {
            setState(() {
              _currentCreature = attributes;
            });
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentCreature = result;
      });

      _conversation = _conversation.addMessage(
        'Updated ${result.customName}! ${result.fullDescription}',
        false,
      );

      await _ttsService.speak('Updated ${result.customName}! ${result.fullDescription}');
    }
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: MinecraftTheme.dirtBrown,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.deepStone,
        elevation: 0,
        title: MinecraftText(
          l10n.creatorTitle.toUpperCase(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MinecraftTheme.goldOre,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: MinecraftTheme.minecraftButton(),
            child: Icon(
              Icons.arrow_back,
              color: MinecraftTheme.textLight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MinecraftTheme.grassGreen.withOpacity(0.3),
              MinecraftTheme.dirtBrown,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crafta Avatar (like a mob head)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: MinecraftTheme.emerald,
                    border: Border.all(
                      color: MinecraftTheme.deepStone,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 50,
                    color: MinecraftTheme.textLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Speech Bubble (like a chat message)
                MinecraftPanel(
                  backgroundColor: MinecraftTheme.slotBackground.withOpacity(0.95),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      MinecraftText(
                        _recognizedText.isEmpty
                          ? _getGreetingForItemType()
                          : _recognizedText,
                        fontSize: 14,
                        color: _recognizedText.isEmpty
                          ? MinecraftTheme.textLight
                          : MinecraftTheme.goldOre,
                        textAlign: TextAlign.center,
                      ),
                      // Show partial results during listening
                      if (_partialText.isNotEmpty && _isListening) ...[
                        const SizedBox(height: 8),
                        MinecraftText(
                          'Listening: $_partialText...',
                          fontSize: 12,
                          color: MinecraftTheme.diamond.withOpacity(0.7),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Voice Feedback Widget
                if (_isListening)
                  VoiceFeedbackWidget(
                    isListening: _isListening,
                    soundLevel: _soundLevel,
                    style: VoiceFeedbackStyle.pulse,
                  ),

                if (_isListening) const SizedBox(height: 24),

                // Microphone Button (like a crafting button with redstone glow)
                GestureDetector(
                  onTapDown: (_) => _startListening(),
                  onTapUp: (_) => _stopListening(),
                  onTapCancel: () => _stopListening(),
                  child: AnimatedBuilder(
                    animation: _isListening ? _pulseAnimation : AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: _isListening
                              ? MinecraftTheme.redstone
                              : MinecraftTheme.emerald,
                            border: Border.all(
                              color: _isListening
                                ? MinecraftTheme.lavaOrange
                                : MinecraftTheme.deepStone,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening
                                  ? MinecraftTheme.redstone
                                  : MinecraftTheme.emerald).withOpacity(0.6),
                                offset: const Offset(4, 4),
                                blurRadius: _isListening ? 10 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            size: 50,
                            color: MinecraftTheme.textLight,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Status Text
                MinecraftText(
                  _isListening
                    ? l10n.listening.toUpperCase()
                    : l10n.tapToSpeak,
                  fontSize: 14,
                  color: _isListening ? MinecraftTheme.redstone : MinecraftTheme.stoneGray,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Text Input (like a sign/book interface)
                MinecraftPanel(
                  backgroundColor: MinecraftTheme.oakWood.withOpacity(0.9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MinecraftText(
                        l10n.orTypeMessage.toUpperCase(),
                        fontSize: 12,
                        color: MinecraftTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: MinecraftTheme.minecraftSlot(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: MinecraftTheme.textDark,
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.typeHere,
                            hintStyle: TextStyle(
                              color: MinecraftTheme.stoneGray,
                              fontFamily: 'monospace',
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _processTextInput,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _sendButtonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _sendButtonAnimation.value,
                            child: MinecraftButton(
                              text: l10n.send.toUpperCase(),
                              onPressed: () => _processTextInput(_textController.text),
                              color: MinecraftTheme.emerald,
                              icon: Icons.send,
                              height: 48,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Advanced Customization (like enchantment table)
                if (_currentCreature != null)
                  MinecraftPanel(
                    backgroundColor: MinecraftTheme.netherPortal.withOpacity(0.2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_fix_high,
                              color: MinecraftTheme.netherPortal,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            MinecraftText(
                              'ENCHANT YOUR CREATURE',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: MinecraftTheme.netherPortal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MinecraftText(
                          l10n.customizeOptions,
                          fontSize: 12,
                          color: MinecraftTheme.stoneGray,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        MinecraftButton(
                          text: l10n.customize.toUpperCase(),
                          onPressed: () => _openAdvancedCustomization(),
                          color: MinecraftTheme.netherPortal,
                          icon: Icons.palette,
                          height: 48,
                        ),
                      ],
                    ),
                  ),

                if (_isProcessing) ...[
                  const SizedBox(height: 24),
                  MinecraftPanel(
                    backgroundColor: MinecraftTheme.slotBackground.withOpacity(0.9),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated crafting (like furnace smelting)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(MinecraftTheme.lavaOrange),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MinecraftText(
                          l10n.creating.toUpperCase(),
                          fontSize: 14,
                          color: MinecraftTheme.goldOre,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],

                // Extra padding at bottom for scrolling
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Extract colors from creature attributes for achievement tracking
  List<String> _extractColorsFromAttributes(EnhancedCreatureAttributes attributes) {
    final colors = <String>[];
    
    // Extract primary color
    colors.add(_colorToString(attributes.primaryColor));
    
    // Extract secondary color
    colors.add(_colorToString(attributes.secondaryColor));
    
    // Extract accent color
    colors.add(_colorToString(attributes.accentColor));
    
    return colors;
  }

  /// Convert Color to string for tracking
  String _colorToString(Color color) {
    // Convert color to a simple string representation
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.cyan) return 'cyan';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.grey) return 'grey';
    if (color == Colors.black) return 'black';
    if (color == Colors.white) return 'white';
    return 'custom';
  }

  /// Get greeting text based on selected item type
  String _getGreetingForItemType() {
    final l10n = AppLocalizations.of(context);

    switch (_selectedItemType) {
      case ItemType.creature:
        return l10n.craftaGreeting;
      case ItemType.weapon:
        return 'Hi! Tell me about the ${widget.material?.displayName ?? ''} weapon you want to create! Like "a flaming sword" or "a powerful bow"!';
      case ItemType.armor:
        return 'Hi! Tell me about the ${widget.material?.displayName ?? ''} armor you want to create! Like "a shiny helmet" or "a dragon chestplate"!';
      case ItemType.furniture:
        return 'Hi! Tell me about the ${widget.material?.displayName ?? ''} furniture you want to create! Like "a cozy chair" or "a royal throne"!';
      case ItemType.tool:
        return 'Hi! Tell me about the ${widget.material?.displayName ?? ''} tool you want to create! Like "a super pickaxe" or "a fast shovel"!';
      case ItemType.decoration:
        return 'Hi! Tell me about the decoration you want to create! Like "a flower pot" or "a cool statue"!';
      case ItemType.vehicle:
        return 'Hi! Tell me about the vehicle you want to create! Like "a race car" or "a flying spaceship"!';
    }
  }
}
