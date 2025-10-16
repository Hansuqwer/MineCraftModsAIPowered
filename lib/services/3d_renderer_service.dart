import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:math' as math;

/// 3D Creature Renderer Service
/// Handles 3D rendering of creatures with animations and effects
class Renderer3DService {
  static const double _defaultSize = 200.0;
  static const double _animationSpeed = 1.0;
  
  /// Render a 3D creature based on attributes
  Widget renderCreature3D({
    required Map<String, dynamic> creatureAttributes,
    double size = _defaultSize,
    bool isAnimated = true,
    bool enableRotation = true,
    bool enableFloating = true,
  }) {
    final creatureType = creatureAttributes['creatureType'] ?? 'cow';
    final color = creatureAttributes['color'] ?? 'rainbow';
    final effects = creatureAttributes['effects'] as List<String>? ?? [];
    final creatureSize = creatureAttributes['size'] ?? 'normal';
    
    return _Creature3DWidget(
      creatureType: creatureType,
      color: color,
      effects: effects,
      creatureSize: creatureSize,
      size: size,
      isAnimated: isAnimated,
      enableRotation: enableRotation,
      enableFloating: enableFloating,
    );
  }
  
  /// Get 3D creature model data
  Map<String, dynamic> getCreatureModel(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'dragon':
        return {
          'shape': 'dragon',
          'vertices': _generateDragonVertices(),
          'texture': 'scales',
          'animation': 'fly'
        };
      case 'unicorn':
        return {
          'shape': 'unicorn',
          'vertices': _generateUnicornVertices(),
          'texture': 'fur',
          'animation': 'gallop'
        };
      case 'phoenix':
        return {
          'shape': 'phoenix',
          'vertices': _generatePhoenixVertices(),
          'texture': 'feathers',
          'animation': 'soar'
        };
      case 'griffin':
        return {
          'shape': 'griffin',
          'vertices': _generateGriffinVertices(),
          'texture': 'feathers_scales',
          'animation': 'glide'
        };
      case 'sword':
        return {
          'shape': 'sword',
          'vertices': _generateSwordVertices(),
          'texture': 'metal',
          'animation': 'glow'
        };
      case 'wand':
        return {
          'shape': 'wand',
          'vertices': _generateWandVertices(),
          'texture': 'wood',
          'animation': 'sparkle'
        };
      default:
        return {
          'shape': 'basic',
          'vertices': _generateBasicVertices(),
          'texture': 'smooth',
          'animation': 'bounce'
        };
    }
  }
  
  /// Generate dragon vertices for 3D model
  List<vm.Vector3> _generateDragonVertices() {
    return [
      // Body
      vm.Vector3(0, 0, 0),
      vm.Vector3(2, 0, 0),
      vm.Vector3(2, 1, 0),
      vm.Vector3(0, 1, 0),
      // Head
      vm.Vector3(2, 0.5, 0),
      vm.Vector3(3, 0.5, 0),
      vm.Vector3(3, 1, 0),
      vm.Vector3(2, 1, 0),
      // Wings
      vm.Vector3(1, 0, -1),
      vm.Vector3(1, 0, 1),
      vm.Vector3(1, 1, -1),
      vm.Vector3(1, 1, 1),
    ];
  }
  
  /// Generate unicorn vertices for 3D model
  List<vm.Vector3> _generateUnicornVertices() {
    return [
      // Body
      vm.Vector3(0, 0, 0),
      vm.Vector3(2, 0, 0),
      vm.Vector3(2, 1, 0),
      vm.Vector3(0, 1, 0),
      // Head
      vm.Vector3(2, 0.5, 0),
      vm.Vector3(3, 0.5, 0),
      vm.Vector3(3, 1, 0),
      vm.Vector3(2, 1, 0),
      // Horn
      vm.Vector3(2.5, 1, 0),
      vm.Vector3(2.5, 1.5, 0),
    ];
  }
  
  /// Generate phoenix vertices for 3D model
  List<vm.Vector3> _generatePhoenixVertices() {
    return [
      // Body
      vm.Vector3(0, 0, 0),
      vm.Vector3(1.5, 0, 0),
      vm.Vector3(1.5, 1, 0),
      vm.Vector3(0, 1, 0),
      // Wings
      vm.Vector3(0.5, 0, -1.5),
      vm.Vector3(0.5, 0, 1.5),
      vm.Vector3(0.5, 1, -1.5),
      vm.Vector3(0.5, 1, 1.5),
      // Tail
      vm.Vector3(0, 0.5, 0),
      vm.Vector3(-1, 0.5, 0),
    ];
  }
  
  /// Generate griffin vertices for 3D model
  List<vm.Vector3> _generateGriffinVertices() {
    return [
      // Body
      vm.Vector3(0, 0, 0),
      vm.Vector3(2, 0, 0),
      vm.Vector3(2, 1, 0),
      vm.Vector3(0, 1, 0),
      // Head
      vm.Vector3(2, 0.5, 0),
      vm.Vector3(3, 0.5, 0),
      vm.Vector3(3, 1, 0),
      vm.Vector3(2, 1, 0),
      // Wings
      vm.Vector3(1, 0, -1),
      vm.Vector3(1, 0, 1),
      vm.Vector3(1, 1, -1),
      vm.Vector3(1, 1, 1),
      // Lion body
      vm.Vector3(0, 0, 0),
      vm.Vector3(2, 0, 0),
      vm.Vector3(2, 0.5, 0),
      vm.Vector3(0, 0.5, 0),
    ];
  }
  
  /// Generate sword vertices for 3D model
  List<vm.Vector3> _generateSwordVertices() {
    return [
      // Blade
      vm.Vector3(0, 0, 0),
      vm.Vector3(0.2, 0, 0),
      vm.Vector3(0.2, 3, 0),
      vm.Vector3(0, 3, 0),
      // Handle
      vm.Vector3(0.1, -0.5, 0),
      vm.Vector3(0.3, -0.5, 0),
      vm.Vector3(0.3, 0, 0),
      vm.Vector3(0.1, 0, 0),
      // Guard
      vm.Vector3(-0.2, 0, 0),
      vm.Vector3(0.4, 0, 0),
      vm.Vector3(0.4, 0.1, 0),
      vm.Vector3(-0.2, 0.1, 0),
    ];
  }
  
  /// Generate wand vertices for 3D model
  List<vm.Vector3> _generateWandVertices() {
    return [
      // Wand shaft
      vm.Vector3(0, 0, 0),
      vm.Vector3(0.1, 0, 0),
      vm.Vector3(0.1, 2, 0),
      vm.Vector3(0, 2, 0),
      // Crystal tip
      vm.Vector3(0.05, 2, 0),
      vm.Vector3(0.15, 2, 0),
      vm.Vector3(0.15, 2.3, 0),
      vm.Vector3(0.05, 2.3, 0),
    ];
  }
  
  /// Generate basic vertices for 3D model
  List<vm.Vector3> _generateBasicVertices() {
    return [
      // Basic cube
      vm.Vector3(0, 0, 0),
      vm.Vector3(1, 0, 0),
      vm.Vector3(1, 1, 0),
      vm.Vector3(0, 1, 0),
      vm.Vector3(0, 0, 1),
      vm.Vector3(1, 0, 1),
      vm.Vector3(1, 1, 1),
      vm.Vector3(0, 1, 1),
    ];
  }
  
  /// Get color from string
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
  
  /// Get size multiplier from string
  double _getSizeMultiplier(String size) {
    switch (size.toLowerCase()) {
      case 'tiny':
        return 0.5;
      case 'normal':
        return 1.0;
      case 'big':
        return 1.5;
      case 'huge':
        return 2.0;
      case 'massive':
        return 2.5;
      default:
        return 1.0;
    }
  }
}

/// 3D Creature Widget
class _Creature3DWidget extends StatefulWidget {
  final String creatureType;
  final String color;
  final List<String> effects;
  final String creatureSize;
  final double size;
  final bool isAnimated;
  final bool enableRotation;
  final bool enableFloating;

  const _Creature3DWidget({
    required this.creatureType,
    required this.color,
    required this.effects,
    required this.creatureSize,
    required this.size,
    required this.isAnimated,
    required this.enableRotation,
    required this.enableFloating,
  });

  @override
  State<_Creature3DWidget> createState() => _Creature3DWidgetState();
}

class _Creature3DWidgetState extends State<_Creature3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  
  final Renderer3DService _renderer = Renderer3DService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
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
      duration: const Duration(seconds: 2),
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

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _renderer._getColorFromString(widget.color);
    final sizeMultiplier = _renderer._getSizeMultiplier(widget.creatureSize);
    final finalSize = widget.size * sizeMultiplier;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _floatingAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(_rotationAnimation.value)
            ..translate(0.0, _floatingAnimation.value * 10 - 5)
            ..scale(_pulseAnimation.value),
          child: Container(
            width: finalSize,
            height: finalSize,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                  color.withOpacity(0.4),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: color.withOpacity(0.2),
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
                _build3DCreature(),
                
                // Effects overlay
                if (widget.effects.isNotEmpty) _buildEffectsOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _build3DCreature() {
    final model = _renderer.getCreatureModel(widget.creatureType);
    final iconData = _getCreatureIcon(widget.creatureType);
    
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

  Widget _buildEffectsOverlay() {
    return Stack(
      children: widget.effects.map((effect) {
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
          children: List.generate(8, (index) {
            final angle = (index * math.pi * 2) / 8;
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
                  child: const Icon(
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
            height: 20,
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
              borderRadius: BorderRadius.circular(10),
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
            height: 20,
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
              borderRadius: BorderRadius.circular(10),
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
                color: _renderer._getColorFromString(widget.color)
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
}
