import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/startup_service.dart';
import '../services/app_localizations.dart';
import '../services/tutorial_service.dart';
import '../services/enhanced_speech_service.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';
import 'tutorial_screen.dart';

/// Minecraft-inspired Welcome Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize startup services (deferred to first build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStartup();
      _checkTutorialStatus();
    });

    // Glow animation for title (like enchanted items)
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Float animation for creature icon
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeStartup() async {
    if (mounted) {
      await StartupService.initialize(context);

      // Check if voice calibration is needed
      await _checkVoiceCalibration();
    }
  }

  Future<void> _checkVoiceCalibration() async {
    try {
      final speechService = EnhancedSpeechService();
      await speechService.initialize();

      if (speechService.needsCalibration()) {
        // Wait a bit before showing calibration prompt
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // Show calibration prompt
        final shouldCalibrate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mic, color: Colors.blue),
                SizedBox(width: 12),
                Text('Voice Setup'),
              ],
            ),
            content: const Text(
              'Let\'s set up your voice so Crafta can hear you perfectly! '
              'This only takes a minute.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Skip for Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Set Up Voice'),
              ),
            ],
          ),
        );

        if (shouldCalibrate == true && mounted) {
          await Navigator.pushNamed(context, '/voice-calibration');
        }
      }
    } catch (e) {
      print('Voice calibration check error: $e');
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _startCreating() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/creator');
    }
  }

  Future<void> _startTutorial() async {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TutorialScreen(),
        ),
      );
    }
  }

  Future<void> _checkTutorialStatus() async {
    final shouldShowTutorial = await TutorialService.shouldShowTutorial();
    if (shouldShowTutorial && mounted) {
      // Show a dialog asking if they want to start the tutorial
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Welcome to Crafta!'),
          content: const Text(
            'Would you like to take a quick tutorial to learn how to use Crafta? It only takes a few minutes!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                TutorialService.markTutorialSkipped();
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startTutorial();
              },
              child: const Text('Start Tutorial'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MinecraftTheme.grassGreen.withOpacity(0.6),
              MinecraftTheme.dirtBrown.withOpacity(0.8),
              MinecraftTheme.coalBlack.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minHeight: screenHeight - 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: Logo and title
                  Column(
                    children: [
                      const SizedBox(height: 40),

                      // Animated creature icon (like a Minecraft mob)
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: MinecraftTheme.emerald,
                                border: Border.all(
                                  color: MinecraftTheme.deepStone,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: const Offset(5, 5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Pixelated creature representation
                                  Center(
                                    child: Icon(
                                      Icons.pets,
                                      size: 80,
                                      color: MinecraftTheme.textLight,
                                    ),
                                  ),
                                  // Sparkle effect
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: AnimatedBuilder(
                                      animation: _glowAnimation,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _glowAnimation.value,
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: MinecraftTheme.goldOre,
                                            size: 30,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Title with Minecraft-style glow
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Text(
                            'CRAFTA',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: MinecraftTheme.goldOre,
                              fontFamily: 'monospace',
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: MinecraftTheme.coalBlack,
                                  offset: const Offset(4, 4),
                                  blurRadius: 0,
                                ),
                                Shadow(
                                  color: MinecraftTheme.goldOre.withOpacity(_glowAnimation.value * 0.5),
                                  offset: const Offset(0, 0),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Subtitle in Minecraft panel style
                      MinecraftPanel(
                        backgroundColor: MinecraftTheme.slotBackground.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: MinecraftText(
                          l10n.welcomeSubtitle,
                          fontSize: 16,
                          color: MinecraftTheme.textLight,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // Middle section: Feature highlights
                  MinecraftPanel(
                    backgroundColor: MinecraftTheme.deepStone.withOpacity(0.85),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFeature(
                          icon: Icons.record_voice_over,
                          title: l10n.voiceFirst,
                          description: l10n.voiceFirstDesc,
                          color: MinecraftTheme.diamond,
                        ),
                        const SizedBox(height: 16),
                        _buildFeature(
                          icon: Icons.auto_awesome,
                          title: l10n.aiPowered,
                          description: l10n.aiPoweredDesc,
                          color: MinecraftTheme.netherPortal,
                        ),
                        const SizedBox(height: 16),
                        _buildFeature(
                          icon: Icons.extension,
                          title: l10n.minecraftExport,
                          description: l10n.minecraftExportDesc,
                          color: MinecraftTheme.grassGreen,
                        ),
                      ],
                    ),
                  ),

                  // Bottom section: Buttons
                  Column(
                    children: [
                      // Main start button - Choose what to create
                      MinecraftButton(
                        text: 'CHOOSE WHAT TO CREATE',
                        onPressed: () async {
                          // Show item type selection first
                          final itemType = await Navigator.pushNamed(context, '/item-type-selection');
                          if (itemType != null && mounted) {
                            // If material required, show material selection
                            ItemMaterialType? material;
                            if (itemType is ItemType && itemType != ItemType.creature && itemType != ItemType.decoration && itemType != ItemType.vehicle) {
                              material = await Navigator.pushNamed(context, '/material-selection', arguments: itemType) as ItemMaterialType?;
                              if (material == null) return; // User cancelled material selection
                            }

                            // Then go to creator with selected type and material
                            if (mounted) {
                              Navigator.pushNamed(
                                context,
                                '/creator',
                                arguments: {
                                  'itemType': itemType,
                                  'material': material,
                                },
                              );
                            }
                          }
                        },
                        color: MinecraftTheme.emerald,
                        icon: Icons.auto_awesome,
                        height: 64,
                      ),

                      const SizedBox(height: 16),

                      // Quick start - Create creature (classic mode)
                      MinecraftButton(
                        text: 'QUICK START: CREATURE',
                        onPressed: _startCreating,
                        color: MinecraftTheme.grassGreen,
                        icon: Icons.pets,
                        height: 56,
                      ),

                      const SizedBox(height: 16),

                      // Tutorial button
                      MinecraftButton(
                        text: 'TUTORIAL',
                        onPressed: _startTutorial,
                        color: MinecraftTheme.diamond,
                        icon: Icons.school,
                        height: 56,
                      ),

                      const SizedBox(height: 16),

                      // Enhanced Modern Features button
                      MinecraftButton(
                        text: 'ENHANCED FEATURES',
                        onPressed: () {
                          Navigator.pushNamed(context, '/enhanced-modern');
                        },
                        color: MinecraftTheme.goldOre,
                        icon: Icons.auto_awesome,
                        height: 56,
                      ),

                      const SizedBox(height: 16),

                      // Community Gallery button
                      MinecraftButton(
                        text: 'COMMUNITY GALLERY',
                        onPressed: () {
                          Navigator.pushNamed(context, '/community-gallery');
                        },
                        color: MinecraftTheme.emerald,
                        icon: Icons.people,
                        height: 56,
                      ),

                      const SizedBox(height: 16),

                      // Enhanced Creator button
                      MinecraftButton(
                        text: '🤖 ENHANCED CREATOR',
                        onPressed: () {
                          Navigator.pushNamed(context, '/enhanced-creator');
                        },
                        color: Colors.cyan,
                        icon: Icons.auto_awesome,
                      ),

                      const SizedBox(height: 16),

                      // Kid-Friendly button
                      MinecraftButton(
                        text: '🎮 KID MODE',
                        onPressed: () {
                          Navigator.pushNamed(context, '/kid-friendly');
                        },
                        color: Colors.purple,
                        icon: Icons.child_care,
                        height: 56,
                      ),

                      const SizedBox(height: 16),

                      // Parent settings button
                      MinecraftButton(
                        text: l10n.parentSettings.toUpperCase(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/parent-settings');
                        },
                        color: MinecraftTheme.buttonBackground,
                        icon: Icons.settings,
                        height: 56,
                      ),

                      const SizedBox(height: 24),

                      // Version info (like Minecraft)
                      MinecraftText(
                        'Crafta v1.5.0',
                        fontSize: 12,
                        color: MinecraftTheme.stoneGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        // Icon in a slot
        Container(
          width: 48,
          height: 48,
          decoration: MinecraftTheme.minecraftSlot(),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MinecraftText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              const SizedBox(height: 4),
              MinecraftText(
                description,
                fontSize: 14,
                color: MinecraftTheme.stoneGray,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
