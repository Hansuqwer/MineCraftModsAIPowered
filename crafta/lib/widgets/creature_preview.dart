import 'package:flutter/material.dart';
import 'dart:math' as math;

class CreaturePreview extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double size;
  final bool isAnimated;

  const CreaturePreview({
    super.key,
    required this.creatureAttributes,
    this.size = 200.0,
    this.isAnimated = true,
  });

  @override
  State<CreaturePreview> createState() => _CreaturePreviewState();
}

class _CreaturePreviewState extends State<CreaturePreview>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _sparkleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Bounce animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main creature body
          _buildCreatureBody(),
          
          // Effects overlay
          if (widget.creatureAttributes['effects'] != null)
            _buildEffectsOverlay(),
          
          // Sparkles for magical creatures
          if (widget.creatureAttributes['effects']?.contains('sparkles') == true ||
              widget.creatureAttributes['effects']?.contains('magic') == true)
            _buildSparkles(),
        ],
      ),
    );
  }

  Widget _buildCreatureBody() {
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'cow';
    final color = widget.creatureAttributes['color'] ?? 'rainbow';
    final size = widget.creatureAttributes['size'] ?? 'normal';
    
    return AnimatedBuilder(
      animation: widget.isAnimated ? _bounceAnimation : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: _getCreatureIcon(creatureType, color, size),
        );
      },
    );
  }

  Widget _getCreatureIcon(String creatureType, String color, String size) {
    final iconSize = _getIconSize(size);
    final iconColor = _getColorFromString(color);
    
    IconData iconData;
    switch (creatureType.toLowerCase()) {
      // Creatures
      case 'dragon':
        iconData = Icons.local_fire_department;
        break;
      case 'unicorn':
        iconData = Icons.auto_awesome;
        break;
      case 'phoenix':
        iconData = Icons.whatshot;
        break;
      case 'griffin':
        iconData = Icons.flight;
        break;
      case 'cat':
        iconData = Icons.pets;
        break;
      case 'dog':
        iconData = Icons.pets;
        break;
      case 'horse':
        iconData = Icons.pets;
        break;
      case 'sheep':
        iconData = Icons.pets;
        break;
      case 'pig':
        iconData = Icons.pets;
        break;
      case 'chicken':
        iconData = Icons.pets;
        break;
      case 'cow':
        iconData = Icons.pets;
        break;
      // Weapons and items
      case 'sword':
        iconData = Icons.sports_martial_arts;
        break;
      case 'axe':
        iconData = Icons.construction;
        break;
             case 'bow':
               iconData = Icons.arrow_forward;
        break;
      case 'shield':
        iconData = Icons.shield;
        break;
      case 'wand':
        iconData = Icons.auto_awesome;
        break;
             case 'staff':
               iconData = Icons.auto_awesome;
        break;
      case 'hammer':
        iconData = Icons.build;
        break;
      case 'spear':
        iconData = Icons.sports_martial_arts;
        break;
      case 'dagger':
        iconData = Icons.sports_martial_arts;
        break;
      case 'mace':
        iconData = Icons.sports_martial_arts;
        break;
      default:
        iconData = Icons.pets;
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            iconColor,
            iconColor.withOpacity(0.7),
            iconColor.withOpacity(0.4),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: iconColor.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main icon
          Icon(
            iconData,
            size: iconSize * 0.6,
            color: Colors.white,
          ),
          // Sparkle overlay for magical creatures
          if (creatureType.toLowerCase() == 'unicorn' || 
              creatureType.toLowerCase() == 'dragon' ||
              creatureType.toLowerCase() == 'phoenix')
            Positioned(
              top: iconSize * 0.1,
              right: iconSize * 0.1,
              child: Icon(
                Icons.auto_awesome,
                size: iconSize * 0.2,
                color: Colors.yellow,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEffectsOverlay() {
    final effects = widget.creatureAttributes['effects'] as List<String>? ?? [];
    
    return Stack(
      children: effects.map((effect) {
        switch (effect.toLowerCase()) {
          case 'fire':
            return _buildFireEffect();
          case 'ice':
            return _buildIceEffect();
          case 'lightning':
            return _buildLightningEffect();
          case 'glow':
            return _buildGlowEffect();
          case 'sparkles':
            return _buildSparkleEffect();
          case 'magic':
            return _buildMagicEffect();
          case 'rainbow':
            return _buildRainbowEffect();
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  Widget _buildFireEffect() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        // Check if it's black fire
        final isBlackFire = widget.creatureAttributes['color']?.toString().toLowerCase().contains('black') == true;
        
        return Positioned(
          bottom: 0,
          child: Container(
            width: widget.size * 0.8,
            height: 25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isBlackFire ? [
                  Colors.black.withOpacity(_sparkleAnimation.value * 0.8),
                  Colors.grey[800]!.withOpacity(_sparkleAnimation.value * 0.6),
                  Colors.grey[600]!.withOpacity(_sparkleAnimation.value * 0.4),
                ] : [
                  Colors.orange.withOpacity(_sparkleAnimation.value),
                  Colors.red.withOpacity(_sparkleAnimation.value),
                  Colors.yellow.withOpacity(_sparkleAnimation.value),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isBlackFire ? [
                BoxShadow(
                  color: Colors.black.withOpacity(_sparkleAnimation.value * 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : [
                BoxShadow(
                  color: Colors.orange.withOpacity(_sparkleAnimation.value * 0.3),
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
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          child: Container(
            width: widget.size * 0.6,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(_sparkleAnimation.value * 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightningEffect() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Positioned(
          right: 0,
          child: Container(
            width: 8,
            height: widget.size * 0.8,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(_sparkleAnimation.value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.2,
          height: widget.size * 1.2,
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(_sparkleAnimation.value * 0.3),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSparkleEffect() {
    return _buildSparkles();
  }

  Widget _buildMagicEffect() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Positioned(
          top: widget.size * 0.2,
          left: widget.size * 0.1,
          child: Icon(
            Icons.auto_awesome,
            size: 20,
            color: Colors.purple.withOpacity(_sparkleAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildRainbowEffect() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.2,
          height: widget.size * 1.2,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.red.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.orange.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.yellow.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.green.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.blue.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.indigo.withOpacity(_sparkleAnimation.value * 0.5),
                Colors.purple.withOpacity(_sparkleAnimation.value * 0.5),
              ],
              stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(_sparkleAnimation.value * 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final angle = (index * math.pi * 2) / 12;
            final radius = widget.size * 0.5;
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            // Vary sparkle sizes and colors
            final sparkleSize = 8 + (index % 3) * 4;
            final sparkleColors = [Colors.yellow, Colors.white, Colors.cyan, Colors.pink];
            final sparkleColor = sparkleColors[index % sparkleColors.length];
            
            return Positioned(
              left: widget.size / 2 + x - sparkleSize / 2,
              top: widget.size / 2 + y - sparkleSize / 2,
              child: Transform.rotate(
                angle: _sparkleAnimation.value * math.pi * 2,
                child: Opacity(
                  opacity: _sparkleAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: sparkleSize.toDouble(),
                    color: sparkleColor,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _getIconSize(String size) {
    switch (size.toLowerCase()) {
      case 'tiny':
        return widget.size * 0.4;
      case 'big':
      case 'huge':
        return widget.size * 0.9;
      case 'massive':
        return widget.size * 1.0;
      default:
        return widget.size * 0.7;
    }
  }

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'rainbow':
        return Colors.purple; // Default for rainbow
      default:
        return Colors.purple;
    }
  }
}
