import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/3d_renderer_service.dart';
import 'dart:math' as math;

/// 3D Creature Preview Widget
/// Displays creatures in 3D with animations and effects
class Creature3DPreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double size;
  final bool isAnimated;
  final bool enableRotation;
  final bool enableFloating;
  final bool enableInteraction;

  const Creature3DPreview({
    super.key,
    required this.creatureAttributes,
    this.size = 200,
    this.isAnimated = true,
    this.enableRotation = true,
    this.enableFloating = true,
    this.enableInteraction = true,
  });

  @override
  State<Creature3DPreview> createState() => _Creature3DPreviewState();
}

class _Creature3DPreviewState extends State<Creature3DPreview>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _interactionController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _interactionAnimation;
  
  final Renderer3DService _renderer = Renderer3DService();
  bool _isInteracting = false;
  double _rotationSpeed = 1.0;
  double _floatingSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupInteraction();
  }

  void _initializeAnimations() {
    // Rotation animation
    _rotationController = AnimationController(
      duration: Duration(milliseconds: (4000 / _rotationSpeed).round()),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Floating animation
    _floatingController = AnimationController(
      duration: Duration(milliseconds: (2000 / _floatingSpeed).round()),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Interaction animation
    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _interactionAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _interactionController,
      curve: Curves.elasticOut,
    ));

    if (widget.isAnimated) {
      if (widget.enableRotation) {
        _rotationController.repeat();
      }
      if (widget.enableFloating) {
        _floatingController.repeat(reverse: true);
      }
      _pulseController.repeat(reverse: true);
    }
  }

  void _setupInteraction() {
    if (widget.enableInteraction) {
      // Add haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _interactionController.dispose();
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

    // Speed up animations temporarily
    _rotationSpeed = 0.5;
    _floatingSpeed = 0.5;
    _updateAnimationSpeeds();
  }

  void _updateAnimationSpeeds() {
    _rotationController.duration = Duration(milliseconds: (4000 / _rotationSpeed).round());
    _floatingController.duration = Duration(milliseconds: (2000 / _floatingSpeed).round());
    
    // Reset speeds after interaction
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _rotationSpeed = 1.0;
        _floatingSpeed = 1.0;
        _updateAnimationSpeeds();
      }
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
        ]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(_rotationAnimation.value)
              ..translate(0.0, _floatingAnimation.value * 10 - 5)
              ..scale(_pulseAnimation.value * _interactionAnimation.value),
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
                  // 3D creature representation
                  _build3DCreature(creatureType),
                  
                  // Effects overlay
                  if (effects.isNotEmpty) _buildEffectsOverlay(effects),
                  
                  // Interaction indicator
                  if (_isInteracting) _buildInteractionIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _build3DCreature(String creatureType) {
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
      case 'spear':
        return Icons.sports_martial_arts;
      case 'dagger':
        return Icons.sports_martial_arts;
      case 'mace':
        return Icons.sports_martial_arts;
      case 'axe':
        return Icons.construction;
      case 'pickaxe':
        return Icons.construction;
      case 'shovel':
        return Icons.construction;
      case 'hoe':
        return Icons.construction;
      case 'fishing_rod':
        return Icons.sports_martial_arts;
      case 'trident':
        return Icons.sports_martial_arts;
      case 'helmet':
        return Icons.shield;
      case 'chestplate':
        return Icons.shield;
      case 'leggings':
        return Icons.shield;
      case 'boots':
        return Icons.shield;
      case 'diamond':
        return Icons.diamond;
      case 'emerald':
        return Icons.diamond;
      case 'ruby':
        return Icons.diamond;
      case 'crystal':
        return Icons.diamond;
      case 'gem':
        return Icons.diamond;
      case 'stone':
        return Icons.terrain;
      case 'wood':
        return Icons.terrain;
      case 'iron':
        return Icons.terrain;
      case 'gold':
        return Icons.terrain;
      case 'netherite':
        return Icons.terrain;
      case 'apple':
        return Icons.apple;
      case 'bread':
        return Icons.bakery_dining;
      case 'cake':
        return Icons.cake;
      case 'cookie':
        return Icons.cookie;
      case 'potion':
        return Icons.local_drink;
      case 'elixir':
        return Icons.local_drink;
      case 'book':
        return Icons.menu_book;
      case 'scroll':
        return Icons.menu_book;
      case 'orb':
        return Icons.circle;
      case 'crystal_ball':
        return Icons.circle;
      case 'amulet':
        return Icons.circle;
      case 'ring':
        return Icons.circle;
      case 'necklace':
        return Icons.circle;
      case 'crown':
        return Icons.circle;
      case 'tiara':
        return Icons.circle;
      default:
        return Icons.pets;
    }
  }

  Widget _buildEffectsOverlay(List<String> effects) {
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
          children: List.generate(12, (index) {
            final angle = (index * math.pi * 2) / 12;
            final radius = widget.size * 0.4;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: widget.size / 2 + x - 8,
              top: widget.size / 2 + y - 8,
              child: Transform.rotate(
                angle: _pulseAnimation.value * math.pi * 2,
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
            height: 25,
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(_pulseAnimation.value * 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
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
            height: 25,
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(_pulseAnimation.value * 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
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
              size: widget.size * 0.6 * _pulseAnimation.value,
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
              size: widget.size * 0.6 * _pulseAnimation.value,
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
          width: widget.size * 1.2,
          height: widget.size * 1.2,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(_pulseAnimation.value * 0.5),
                Colors.orange.withOpacity(_pulseAnimation.value * 0.5),
                Colors.yellow.withOpacity(_pulseAnimation.value * 0.5),
                Colors.green.withOpacity(_pulseAnimation.value * 0.5),
                Colors.blue.withOpacity(_pulseAnimation.value * 0.5),
                Colors.indigo.withOpacity(_pulseAnimation.value * 0.5),
                Colors.purple.withOpacity(_pulseAnimation.value * 0.5),
              ],
              stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(_pulseAnimation.value * 0.3),
                blurRadius: 30,
                spreadRadius: 5,
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
          width: widget.size * 1.1,
          height: widget.size * 1.1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getColorFromString(widget.creatureAttributes['color'] ?? 'rainbow')
                    .withOpacity(_pulseAnimation.value * 0.5),
                blurRadius: 50,
                spreadRadius: 10,
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
                  Colors.white.withOpacity(_pulseAnimation.value * 0.3),
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
          children: List.generate(20, (index) {
            final angle = (index * math.pi * 2) / 20;
            final radius = widget.size * 0.6;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: widget.size / 2 + x - 4,
              top: widget.size / 2 + y - 4,
              child: Transform.rotate(
                angle: _pulseAnimation.value * math.pi * 4,
                child: Opacity(
                  opacity: _pulseAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 8,
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
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(_interactionAnimation.value),
              width: 3,
            ),
          ),
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
