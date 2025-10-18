import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/startup_service.dart';
import '../services/app_localizations.dart';
import '../theme/minecraft_theme.dart';

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
                      // Main start button
                      MinecraftButton(
                        text: l10n.getStarted.toUpperCase(),
                        onPressed: _startCreating,
                        color: MinecraftTheme.emerald,
                        icon: Icons.play_arrow,
                        height: 64,
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
