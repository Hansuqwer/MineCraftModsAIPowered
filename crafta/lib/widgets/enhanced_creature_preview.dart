import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/animation_service.dart';
import 'dart:math' as math;

/// Enhanced Creature Preview Widget
/// Displays creatures with advanced animations and effects
class EnhancedCreaturePreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double size;
  final bool isAnimated;
  final bool enableInteraction;
  final bool enableAdvancedEffects;

  const EnhancedCreaturePreview({
    super.key,
    required this.creatureAttributes,
    this.size = 200,
    this.isAnimated = true,
    this.enableInteraction = true,
    this.enableAdvancedEffects = true,
  });

  @override
  State<EnhancedCreaturePreview> createState() => _EnhancedCreaturePreviewState();
}

class _EnhancedCreaturePreviewState extends State<EnhancedCreaturePreview>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _interactionController;
  late AnimationController _celebrationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _interactionAnimation;
  late Animation<double> _celebrationAnimation;
  
  List<AnimationController> _effectControllers = [];
  bool _isInteracting = false;
  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupEffectAnimations();
  }

  void _initializeAnimations() {
    // Rotation animation
    _rotationController = AnimationService.createRotationAnimation(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Floating animation
    _floatingController = AnimationService.createFloatingAnimation(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseController = AnimationService.createPulseAnimation(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Interaction animation
    _interactionController = AnimationService.createInteractionAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _interactionAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _interactionController,
      curve: Curves.elasticOut,
    ));

    // Celebration animation
    _celebrationController = AnimationService.createCelebrationAnimation(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _celebrationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    if (widget.isAnimated) {
      _rotationController.repeat();
      _floatingController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    }
  }

  void _setupEffectAnimations() {
    if (!widget.enableAdvancedEffects) return;

    final effects = widget.creatureAttributes['effects'] as List<String>? ?? [];
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'cow';
    
    // Get animations for creature type
    final creatureAnimations = AnimationService.getAnimationsForCreature(creatureType);
    
    // Get animations for effects
    final effectAnimations = <String>[];
    for (final effect in effects) {
      effectAnimations.addAll(AnimationService.getAnimationsForEffect(effect));
    }
    
    // Create unique animations
    final allAnimations = {...creatureAnimations, ...effectAnimations}.toList();
    
    for (int i = 0; i < allAnimations.length; i++) {
      final animationType = allAnimations[i];
      final controller = _createAnimationController(animationType, i);
      _effectControllers.add(controller);
    }
  }

  AnimationController _createAnimationController(String animationType, int index) {
    switch (animationType) {
      case 'sparkle':
        return AnimationService.createSparkleAnimation(vsync: this);
      case 'fire':
        return AnimationService.createFireAnimation(vsync: this);
      case 'ice':
        return AnimationService.createShimmerAnimation(vsync: this);
      case 'lightning':
        return AnimationService.createLightningAnimation(vsync: this);
      case 'magic':
        return AnimationService.createMagicAnimation(vsync: this);
      case 'rainbow':
        return AnimationService.createRainbowAnimation(vsync: this);
      case 'glow':
        return AnimationService.createGlowAnimation(vsync: this);
      case 'shimmer':
        return AnimationService.createShimmerAnimation(vsync: this);
      case 'glitter':
        return AnimationService.createGlitterAnimation(vsync: this);
      case 'flying':
        return AnimationService.createFlyingAnimation(vsync: this);
      case 'swimming':
        return AnimationService.createSwimmingAnimation(vsync: this);
      case 'running':
        return AnimationService.createRunningAnimation(vsync: this);
      case 'jumping':
        return AnimationService.createJumpingAnimation(vsync: this);
      case 'climbing':
        return AnimationService.createClimbingAnimation(vsync: this);
      case 'digging':
        return AnimationService.createDiggingAnimation(vsync: this);
      case 'singing':
        return AnimationService.createSingingAnimation(vsync: this);
      case 'dancing':
        return AnimationService.createDancingAnimation(vsync: this);
      case 'teleporting':
        return AnimationService.createTeleportingAnimation(vsync: this);
      case 'transforming':
        return AnimationService.createTransformingAnimation(vsync: this);
      case 'breathing':
        return AnimationService.createBreathingAnimation(vsync: this);
      case 'heartbeat':
        return AnimationService.createHeartbeatAnimation(vsync: this);
      case 'explosion':
        return AnimationService.createExplosionAnimation(vsync: this);
      case 'implosion':
        return AnimationService.createImplosionAnimation(vsync: this);
      case 'morphing':
        return AnimationService.createMorphingAnimation(vsync: this);
      case 'teleportation':
        return AnimationService.createTeleportationAnimation(vsync: this);
      case 'transformation':
        return AnimationService.createTransformationAnimation(vsync: this);
      case 'levitation':
        return AnimationService.createLevitationAnimation(vsync: this);
      case 'hovering':
        return AnimationService.createHoveringAnimation(vsync: this);
      case 'wave':
        return AnimationService.createWaveAnimation(vsync: this);
      case 'spiral':
        return AnimationService.createSpiralAnimation(vsync: this);
      case 'orbit':
        return AnimationService.createOrbitAnimation(vsync: this);
      case 'staggered':
        return AnimationService.createStaggeredAnimation(
          vsync: this,
          index: index,
          total: _effectControllers.length,
        );
      default:
        return AnimationService.createPulseAnimation(vsync: this);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _interactionController.dispose();
    _celebrationController.dispose();
    
    for (final controller in _effectControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _handleInteraction() {
    if (!widget.enableInteraction) return;

    setState(() {
      _isInteracting = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Interaction animation
    _interactionController.forward().then((_) {
      _interactionController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isInteracting = false;
          });
        }
      });
    });

    // Trigger celebration
    _triggerCelebration();
  }

  void _triggerCelebration() {
    setState(() {
      _isCelebrating = true;
    });

    _celebrationController.forward().then((_) {
      _celebrationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isCelebrating = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'cow';
    final color = widget.creatureAttributes['color'] ?? 'rainbow';
    final effects = widget.creatureAttributes['effects'] as List<String>? ?? [];
    final size = widget.creatureAttributes['size'] ?? 'normal';

    return GestureDetector(
      onTap: _handleInteraction,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationAnimation,
          _floatingAnimation,
          _pulseAnimation,
          _interactionAnimation,
          _celebrationAnimation,
          ..._effectControllers,
        ]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(_rotationAnimation.value)
              ..translate(0.0, _floatingAnimation.value * 10 - 5)
              ..scale(_pulseAnimation.value * _interactionAnimation.value * _celebrationAnimation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _getColorFromString(color),
                    _getColorFromString(color).withOpacity(0.7),
                    _getColorFromString(color).withOpacity(0.4),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getColorFromString(color).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _getColorFromString(color).withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Enhanced creature representation
                  _buildEnhancedCreature(creatureType),
                  
                  // Advanced effects overlay
                  if (effects.isNotEmpty) _buildAdvancedEffectsOverlay(effects),
                  
                  // Interaction indicator
                  if (_isInteracting) _buildInteractionIndicator(),
                  
                  // Celebration effects
                  if (_isCelebrating) _buildCelebrationEffects(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedCreature(String creatureType) {
    final iconData = _getCreatureIcon(creatureType);
    
    return Icon(
      iconData,
      size: widget.size * 0.6,
      color: Colors.white,
    );
  }

  IconData _getCreatureIcon(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'dragon':
        return Icons.local_fire_department;
      case 'unicorn':
        return Icons.auto_awesome;
      case 'phoenix':
        return Icons.whatshot;
      case 'griffin':
        return Icons.flight;
      case 'sword':
        return Icons.sports_martial_arts;
      case 'wand':
        return Icons.auto_awesome;
      case 'staff':
        return Icons.auto_awesome;
      case 'bow':
        return Icons.arrow_forward;
      case 'shield':
        return Icons.shield;
      case 'hammer':
        return Icons.build;
      default:
        return Icons.pets;
    }
  }

  Widget _buildAdvancedEffectsOverlay(List<String> effects) {
    return Stack(
      children: effects.map((effect) {
        switch (effect) {
          case 'sparkles':
            return _buildSparklesEffect();
          case 'fire':
            return _buildFireEffect();
          case 'ice':
            return _buildIceEffect();
          case 'lightning':
            return _buildLightningEffect();
          case 'magic':
            return _buildMagicEffect();
          case 'rainbow':
            return _buildRainbowEffect();
          case 'glow':
            return _buildGlowEffect();
          case 'shimmer':
            return _buildShimmerEffect();
          case 'glitter':
            return _buildGlitterEffect();
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  Widget _buildSparklesEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(16, (index) {
            final angle = (index * math.pi * 2) / 16;
            final radius = widget.size * 0.5;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: widget.size / 2 + x - 8,
              top: widget.size / 2 + y - 8,
              child: Transform.rotate(
                angle: _pulseAnimation.value * math.pi * 4,
                child: Opacity(
                  opacity: _pulseAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.yellow,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFireEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          child: Container(
            width: widget.size * 0.8,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(_pulseAnimation.value),
                  Colors.red.withOpacity(_pulseAnimation.value),
                  Colors.yellow.withOpacity(_pulseAnimation.value),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(_pulseAnimation.value * 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIceEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          child: Container(
            width: widget.size * 0.8,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue.withOpacity(_pulseAnimation.value),
                  Colors.blue.withOpacity(_pulseAnimation.value),
                  Colors.cyan.withOpacity(_pulseAnimation.value),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(_pulseAnimation.value * 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightningEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Center(
            child: Icon(
              Icons.flash_on,
              size: widget.size * 0.8 * _pulseAnimation.value,
              color: Colors.yellow.withOpacity(_pulseAnimation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMagicEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              size: widget.size * 0.8 * _pulseAnimation.value,
              color: Colors.purple.withOpacity(_pulseAnimation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRainbowEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.3,
          height: widget.size * 1.3,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(_pulseAnimation.value * 0.6),
                Colors.orange.withOpacity(_pulseAnimation.value * 0.6),
                Colors.yellow.withOpacity(_pulseAnimation.value * 0.6),
                Colors.green.withOpacity(_pulseAnimation.value * 0.6),
                Colors.blue.withOpacity(_pulseAnimation.value * 0.6),
                Colors.indigo.withOpacity(_pulseAnimation.value * 0.6),
                Colors.purple.withOpacity(_pulseAnimation.value * 0.6),
              ],
              stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(_pulseAnimation.value * 0.4),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.2,
          height: widget.size * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getColorFromString(widget.creatureAttributes['color'] ?? 'rainbow')
                    .withOpacity(_pulseAnimation.value * 0.6),
                blurRadius: 60,
                spreadRadius: 15,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(_pulseAnimation.value * 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlitterEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(24, (index) {
            final angle = (index * math.pi * 2) / 24;
            final radius = widget.size * 0.7;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: widget.size / 2 + x - 6,
              top: widget.size / 2 + y - 6,
              child: Transform.rotate(
                angle: _pulseAnimation.value * math.pi * 6,
                child: Opacity(
                  opacity: _pulseAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInteractionIndicator() {
    return AnimatedBuilder(
      animation: _interactionAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.6,
          height: widget.size * 1.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(_interactionAnimation.value),
              width: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationEffects() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final angle = (index * math.pi * 2) / 8;
            final radius = widget.size * 0.8 * _celebrationAnimation.value;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: widget.size / 2 + x - 12,
              top: widget.size / 2 + y - 12,
              child: Transform.rotate(
                angle: _celebrationAnimation.value * math.pi * 2,
                child: Icon(
                  Icons.celebration,
                  size: 24,
                  color: Colors.yellow.withOpacity(_celebrationAnimation.value),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rainbow':
        return Colors.purple;
      case 'pink':
        return Colors.pinkAccent;
      case 'blue':
        return Colors.blueAccent;
      case 'gold':
        return Colors.amber;
      case 'red':
        return Colors.redAccent;
      case 'green':
        return Colors.lightGreen;
      case 'purple':
        return Colors.deepPurpleAccent;
      case 'yellow':
        return Colors.yellowAccent;
      case 'orange':
        return Colors.deepOrangeAccent;
      case 'silver':
        return Colors.blueGrey;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
