import 'package:flutter/material.dart';
import '../services/ai_suggestion_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/language_service.dart';
import '../models/enhanced_creature_attributes.dart';
import '../widgets/minecraft_3d_preview.dart';
import '../theme/minecraft_theme.dart';

/// Minecraft 3D Viewer Screen - Shows items exactly as they will look in Minecraft
/// Includes AI suggestions with voice interaction for kids ages 3-5
class Minecraft3DViewerScreen extends StatefulWidget {
  final EnhancedCreatureAttributes creatureAttributes;
  final String creatureName;

  const Minecraft3DViewerScreen({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
  });

  @override
  State<Minecraft3DViewerScreen> createState() => _Minecraft3DViewerScreenState();
}

class _Minecraft3DViewerScreenState extends State<Minecraft3DViewerScreen>
    with TickerProviderStateMixin {
  final AISuggestionService _suggestionService = AISuggestionService();
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();

  bool _isLoading = true;
  bool _isProcessingSuggestion = false;
  bool _isListening = false;
  String? _currentSuggestion;
  late EnhancedCreatureAttributes _currentAttributes;
  late String _currentName;

  // Animations
  late AnimationController _suggestionController;
  late AnimationController _listeningController;
  late Animation<double> _suggestionAnimation;
  late Animation<double> _listeningAnimation;

  @override
  void initState() {
    super.initState();
    _currentAttributes = widget.creatureAttributes;
    _currentName = widget.creatureName;
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.elasticOut,
    );

    _listeningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listeningAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _listeningController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
    
    setState(() {
      _isLoading = false;
    });

    // Auto-generate first suggestion after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      _generateSuggestion();
    });
  }

  Future<void> _generateSuggestion() async {
    if (_isProcessingSuggestion) return;

    setState(() {
      _isProcessingSuggestion = true;
    });

    try {
      final suggestion = await _suggestionService.generateSuggestion(_currentAttributes);
      setState(() {
        _currentSuggestion = suggestion;
      });

      _suggestionController.forward();

      // Ask for voice response
      final userWantsChange = await _suggestionService.askForVoiceResponse(suggestion);

      if (userWantsChange) {
        await _suggestionService.giveExcitedResponse();
        await _applySuggestion(suggestion);
      } else {
        await _suggestionService.giveEncouragingResponse();
        // Generate another suggestion
        Future.delayed(const Duration(seconds: 1), () {
          _generateSuggestion();
        });
      }
    } catch (e) {
      print('Error generating suggestion: $e');
    } finally {
      setState(() {
        _isProcessingSuggestion = false;
        _currentSuggestion = null;
      });
      _suggestionController.reset();
    }
  }

  Future<void> _applySuggestion(String suggestion) async {
    setState(() {
      _isProcessingSuggestion = true;
    });

    try {
      final updatedAttributes = await _suggestionService.applySuggestion(_currentAttributes, suggestion);
      setState(() {
        _currentAttributes = updatedAttributes;
        _currentName = '${updatedAttributes.primaryColor.toString().split('.').last} ${updatedAttributes.baseType}';
      });

      // Show success animation
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate next suggestion after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _generateSuggestion();
      });
    } catch (e) {
      print('Error applying suggestion: $e');
    } finally {
      setState(() {
        _isProcessingSuggestion = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
    });

    _listeningController.repeat(reverse: true);

    try {
      final response = await _speechService.listen();
      if (response != null && response.isNotEmpty) {
        // Process the voice input
        await _processVoiceInput(response);
      }
    } catch (e) {
      print('Error in voice input: $e');
    } finally {
      setState(() {
        _isListening = false;
      });
      _listeningController.stop();
      _listeningController.reset();
    }
  }

  Future<void> _processVoiceInput(String input) async {
    final inputLower = input.toLowerCase();
    
    if (inputLower.contains('yes') || inputLower.contains('ja') || 
        inputLower.contains('yeah') || inputLower.contains('ok')) {
      if (_currentSuggestion != null) {
        await _applySuggestion(_currentSuggestion!);
      }
    } else if (inputLower.contains('no') || inputLower.contains('nej') ||
               inputLower.contains('nope')) {
      await _suggestionService.giveEncouragingResponse();
      Future.delayed(const Duration(seconds: 1), () {
        _generateSuggestion();
      });
    } else if (inputLower.contains('new') || inputLower.contains('ny') ||
               inputLower.contains('different') || inputLower.contains('annat')) {
      _generateSuggestion();
    } else {
      // Try to generate a suggestion based on the input
      await _generateSuggestion();
    }
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    _listeningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simple localization for now
    final l10n = _SimpleLocalizations();

    return Scaffold(
      backgroundColor: MinecraftTheme.dirtBrown,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.deepStone,
        elevation: 0,
        title: MinecraftText(
          'MINECRAFT VIEWER',
          fontSize: 18,
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
        actions: [
          // Voice button
          GestureDetector(
            onTap: _startListening,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: MinecraftTheme.minecraftButton(
                color: _isListening ? MinecraftTheme.redstone : MinecraftTheme.emerald,
              ),
              child: AnimatedBuilder(
                animation: _listeningAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _listeningAnimation.value : 1.0,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: MinecraftTheme.textLight,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
          child: Column(
            children: [
              // 3D Viewer
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _isLoading
                        ? Container(
                            color: MinecraftTheme.stoneGray,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading 3D Preview...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Minecraft3DPreview(
                            creatureAttributes: _currentAttributes.toMap(),
                            modelPath: '',
                            texturePath: '',
                            size: 400,
                            enableRotation: true,
                            enableZoom: true,
                            enableEffects: true,
                          ),
                  ),
                ),
              ),

              // AI Suggestion Panel
              if (_currentSuggestion != null)
                ScaleTransition(
                  scale: _suggestionAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MinecraftTheme.netherPortal.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MinecraftTheme.goldOre,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MinecraftTheme.netherPortal.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: MinecraftTheme.goldOre,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            MinecraftText(
                              'CRAFTA SUGGESTS:',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: MinecraftTheme.goldOre,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MinecraftText(
                          _currentSuggestion!,
                          fontSize: 16,
                          color: MinecraftTheme.textLight,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MinecraftButton(
                              text: 'YES',
                              onPressed: () => _applySuggestion(_currentSuggestion!),
                              color: MinecraftTheme.grassGreen,
                              icon: Icons.check,
                              height: 48,
                            ),
                            MinecraftButton(
                              text: 'NO',
                              onPressed: () {
                                _suggestionService.giveEncouragingResponse();
                                Future.delayed(const Duration(seconds: 1), () {
                                  _generateSuggestion();
                                });
                              },
                              color: MinecraftTheme.lavaOrange,
                              icon: Icons.close,
                              height: 48,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Processing indicator
              if (_isProcessingSuggestion)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinecraftTheme.slotBackground.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(MinecraftTheme.lavaOrange),
                      ),
                      const SizedBox(height: 12),
                      MinecraftText(
                        'CRAFTA IS THINKING...',
                        fontSize: 14,
                        color: MinecraftTheme.goldOre,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),

              // Voice instructions
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MinecraftTheme.oakWood.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MinecraftText(
                  _isListening
                      ? 'LISTENING... SAY YES OR NO'
                      : 'TAP MICROPHONE TO SPEAK',
                  fontSize: 12,
                  color: MinecraftTheme.textDark,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple localizations for the 3D viewer
class _SimpleLocalizations {
  String get yourCreation => 'Your Creation';
  String get craftaSuggestion => 'Crafta Suggestion';
  String get thinkingOfSuggestion => 'Thinking of a suggestion...';
  String get failedToGetSuggestion => 'Failed to get suggestion';
  String get tryAgain => 'Try again';
  String get noProblemLetsTryAnother => 'No problem, let\'s try another suggestion!';
  String get didntUnderstand => 'I didn\'t understand. Please try again.';
  String get greatChangeApplied => 'Great! The change has been applied!';
  String get failedToApplySuggestion => 'Failed to apply suggestion';
  String get applyingChange => 'Applying change...';
  String get yes => 'Yes';
  String get no => 'No';
  String get listeningForResponse => 'Listening for your response...';
  String get exportToMinecraft => 'Export to Minecraft';
}
