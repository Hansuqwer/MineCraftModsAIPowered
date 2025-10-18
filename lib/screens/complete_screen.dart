import 'package:flutter/material.dart';
import '../services/app_localizations.dart';
import '../theme/minecraft_theme.dart';

/// Minecraft-inspired Complete Screen - Looks like achievement unlocked!
class CompleteScreen extends StatefulWidget {
  const CompleteScreen({super.key});

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _achievementController;
  late AnimationController _glowController;
  late Animation<double> _achievementAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Achievement pop-in animation
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _achievementAnimation = CurvedAnimation(
      parent: _achievementController,
      curve: Curves.elasticOut,
    );
    _achievementController.forward();

    // Glow animation (like enchanted items)
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _achievementController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final creatureName = args?['creatureName'] ?? 'Rainbow Cow';
    final creatureType = args?['creatureType'] ?? 'Cow';

    return Scaffold(
      backgroundColor: MinecraftTheme.coalBlack,
      appBar: AppBar(
        backgroundColor: MinecraftTheme.deepStone,
        elevation: 0,
        title: MinecraftText(
          l10n.creationReady.toUpperCase(),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MinecraftTheme.deepStone,
              MinecraftTheme.dirtBrown,
              MinecraftTheme.grassGreen.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Achievement Banner
                ScaleTransition(
                  scale: _achievementAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MinecraftTheme.goldOre,
                          MinecraftTheme.goldOre.withOpacity(0.7),
                        ],
                      ),
                      border: Border.all(
                        color: MinecraftTheme.coalBlack,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MinecraftTheme.goldOre.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        MinecraftText(
                          'ACHIEVEMENT UNLOCKED!',
                          fontSize: 14,
                          color: MinecraftTheme.coalBlack,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        MinecraftText(
                          l10n.amazing.toUpperCase(),
                          fontSize: 24,
                          color: MinecraftTheme.coalBlack,
                          fontWeight: FontWeight.w900,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Creature Display (like an item frame)
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: MinecraftTheme.oakWood,
                        border: Border.all(
                          color: MinecraftTheme.deepStone,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MinecraftTheme.emerald.withOpacity(_glowAnimation.value * 0.6),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            offset: const Offset(5, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Creature icon (enchanted look)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: MinecraftTheme.emerald,
                              border: Border.all(
                                color: MinecraftTheme.goldOre,
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    _getCreatureIcon(creatureType),
                                    size: 70,
                                    color: MinecraftTheme.textLight,
                                  ),
                                ),
                                // Enchantment glimmer
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Opacity(
                                    opacity: _glowAnimation.value,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: MinecraftTheme.goldOre,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          MinecraftText(
                            creatureName.toUpperCase(),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MinecraftTheme.goldOre,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          MinecraftText(
                            l10n.readyForMinecraft,
                            fontSize: 14,
                            color: MinecraftTheme.textDark,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Action Buttons (like hotbar slots)
                MinecraftPanel(
                  backgroundColor: MinecraftTheme.hotbarBackground,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View in 3D button (NEW - shows exactly how it will look in Minecraft)
                      MinecraftButton(
                        text: 'VIEW IN 3D',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/minecraft-3d-viewer',
                            arguments: {
                              'creatureAttributes': _getCreatureAttributesFromArgs(args),
                              'creatureName': creatureName,
                            },
                          );
                        },
                        color: MinecraftTheme.diamond,
                        icon: Icons.view_in_ar,
                        height: 60,
                      ),

                      const SizedBox(height: 12),

                      // Export to Minecraft button
                      MinecraftButton(
                        text: l10n.exportToMinecraft.toUpperCase(),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/export-minecraft',
                            arguments: args,
                          );
                        },
                        color: MinecraftTheme.grassGreen,
                        icon: Icons.upload_file,
                        height: 56,
                      ),

                      const SizedBox(height: 12),

                      // Share button
                      MinecraftButton(
                        text: l10n.shareCreature.toUpperCase(),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/creature-sharing',
                            arguments: args,
                          );
                        },
                        color: MinecraftTheme.diamond,
                        icon: Icons.share,
                        height: 56,
                      ),

                      const SizedBox(height: 12),

                      // Make another button
                      MinecraftButton(
                        text: l10n.makeAnother.toUpperCase(),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/creator',
                            (route) => route.isFirst,
                          );
                        },
                        color: MinecraftTheme.buttonBackground,
                        icon: Icons.add_circle_outline,
                        height: 56,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Next creature suggestion (like villager trade)
                MinecraftPanel(
                  backgroundColor: MinecraftTheme.oakWood.withOpacity(0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: MinecraftTheme.goldOre,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          MinecraftText(
                            l10n.tryThisNext.toUpperCase(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: MinecraftTheme.textDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: MinecraftTheme.minecraftSlot(isSelected: true),
                        child: MinecraftText(
                          _getRandomSuggestion(),
                          fontSize: 14,
                          color: MinecraftTheme.textDark,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Extra padding at bottom
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCreatureIcon(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'dragon':
        return Icons.whatshot;
      case 'unicorn':
        return Icons.stars;
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      default:
        return Icons.favorite;
    }
  }

  String _getRandomSuggestion() {
    final suggestions = [
      'Flying dragon with fire breath',
      'Rainbow unicorn with sparkles',
      'Giant friendly spider',
      'Tiny phoenix with flames',
      'Ice dragon with frost powers',
    ];
    return suggestions[DateTime.now().millisecond % suggestions.length];
  }

  Map<String, dynamic> _getCreatureAttributesFromArgs(Map<String, dynamic>? args) {
    if (args == null) {
      return {
        'creatureType': 'sword',
        'color': 'golden',
        'effects': ['glow'],
        'size': 'normal',
        'abilities': [],
        'personality': 'friendly',
      };
    }

    return {
      'creatureType': args['creatureType'] ?? 'sword',
      'color': args['color'] ?? 'golden',
      'effects': args['effects'] ?? ['glow'],
      'size': args['size'] ?? 'normal',
      'abilities': args['abilities'] ?? [],
      'personality': args['personality'] ?? 'friendly',
    };
  }
}
