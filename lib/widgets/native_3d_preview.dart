import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'dart:math' as math;
import '../models/enhanced_creature_attributes.dart';

/// Native 3D Preview Widget
/// Uses Flutter 3D Controller for mobile-optimized 3D rendering
class Native3DPreview extends StatefulWidget {
  final EnhancedCreatureAttributes creatureAttributes;
  final String creatureName;
  final double size;
  final bool enableRotation;
  final bool enableZoom;
  final bool enableEffects;

  const Native3DPreview({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
    this.size = 300.0,
    this.enableRotation = true,
    this.enableZoom = true,
    this.enableEffects = true,
  });

  @override
  State<Native3DPreview> createState() => _Native3DPreviewState();
}

class _Native3DPreviewState extends State<Native3DPreview>
    with TickerProviderStateMixin {
  late Flutter3DController _controller;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize3DController();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _initialize3DController() {
    _controller = Flutter3DController();
    
    // Load the 3D model based on creature attributes
    _load3DModel();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _rotationController.repeat();
    _scaleController.forward();
  }

  Future<void> _load3DModel() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Generate 3D model based on creature attributes
      final modelData = _generateModelData();
      
      // Load the model into the 3D controller
      await _controller.loadModelFromString(modelData);
      
      // Apply materials and effects
      _applyMaterials();
      _applyEffects();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load 3D model: $e';
      });
    }
  }

  String _generateModelData() {
    // Generate 3D model data based on creature attributes
    final baseType = widget.creatureAttributes.baseType.toLowerCase();
    final size = widget.creatureAttributes.size;
    final primaryColor = widget.creatureAttributes.primaryColor;
    final secondaryColor = widget.creatureAttributes.secondaryColor;
    final hasWings = widget.creatureAttributes.abilities.contains(SpecialAbility.flying);
    final hasFlames = widget.creatureAttributes.glowEffect == GlowEffect.flames;
    final hasGlow = widget.creatureAttributes.glowEffect != GlowEffect.none;

    // Generate model based on type
    if (baseType.contains('sword') || baseType.contains('weapon')) {
      return _generateSwordModel(size, primaryColor, hasFlames, hasGlow);
    } else if (baseType.contains('dragon') || baseType.contains('creature')) {
      return _generateDragonModel(size, primaryColor, secondaryColor, hasWings, hasFlames);
    } else if (baseType.contains('furniture') || baseType.contains('chair') || baseType.contains('couch')) {
      return _generateFurnitureModel(baseType, size, primaryColor, secondaryColor);
    } else if (baseType.contains('armor') || baseType.contains('helmet')) {
      return _generateArmorModel(baseType, size, primaryColor, hasGlow);
    } else if (baseType.contains('tool') || baseType.contains('pickaxe')) {
      return _generateToolModel(baseType, size, primaryColor, hasGlow);
    } else {
      return _generateGenericModel(baseType, size, primaryColor, secondaryColor);
    }
  }

  String _generateSwordModel(CreatureSize size, Color primaryColor, bool hasFlames, bool hasGlow) {
    final scale = _getSizeScale(size);
    final colorHex = _colorToHex(primaryColor);
    
    return '''
    {
      "name": "Minecraft Sword",
      "type": "sword",
      "scale": $scale,
      "color": "$colorHex",
      "hasFlames": $hasFlames,
      "hasGlow": $hasGlow,
      "components": [
        {
          "type": "blade",
          "width": ${0.15 * scale},
          "height": ${1.8 * scale},
          "depth": ${0.08 * scale},
          "color": "$colorHex"
        },
        {
          "type": "handle",
          "width": ${0.1 * scale},
          "height": ${0.6 * scale},
          "depth": ${0.1 * scale},
          "color": "#8B4513"
        },
        {
          "type": "guard",
          "width": ${0.3 * scale},
          "height": ${0.05 * scale},
          "depth": ${0.3 * scale},
          "color": "$colorHex"
        }
      ]
    }
    ''';
  }

  String _generateDragonModel(CreatureSize size, Color primaryColor, Color secondaryColor, bool hasWings, bool hasFlames) {
    final scale = _getSizeScale(size);
    final primaryHex = _colorToHex(primaryColor);
    final secondaryHex = _colorToHex(secondaryColor);
    
    return '''
    {
      "name": "Minecraft Dragon",
      "type": "dragon",
      "scale": $scale,
      "primaryColor": "$primaryHex",
      "secondaryColor": "$secondaryHex",
      "hasWings": $hasWings,
      "hasFlames": $hasFlames,
      "components": [
        {
          "type": "body",
          "width": ${1.0 * scale},
          "height": ${1.2 * scale},
          "depth": ${2.0 * scale},
          "color": "$primaryHex"
        },
        {
          "type": "head",
          "width": ${0.8 * scale},
          "height": ${0.6 * scale},
          "depth": ${0.8 * scale},
          "color": "$primaryHex"
        },
        {
          "type": "tail",
          "width": ${0.3 * scale},
          "height": ${0.3 * scale},
          "depth": ${1.5 * scale},
          "color": "$secondaryHex"
        }
        ${hasWings ? '''
        ,{
          "type": "wing",
          "width": ${1.5 * scale},
          "height": ${0.1 * scale},
          "depth": ${0.8 * scale},
          "color": "$secondaryHex"
        }
        ''' : ''}
      ]
    }
    ''';
  }

  String _generateFurnitureModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    final primaryHex = _colorToHex(primaryColor);
    final secondaryHex = _colorToHex(secondaryColor);
    
    if (baseType.contains('couch') || baseType.contains('sofa')) {
      return '''
      {
        "name": "Minecraft Couch",
        "type": "couch",
        "scale": $scale,
        "primaryColor": "$primaryHex",
        "secondaryColor": "$secondaryHex",
        "components": [
          {
            "type": "seat",
            "width": ${2.0 * scale},
            "height": ${0.3 * scale},
            "depth": ${1.0 * scale},
            "color": "$primaryHex"
          },
          {
            "type": "back",
            "width": ${2.0 * scale},
            "height": ${0.8 * scale},
            "depth": ${0.2 * scale},
            "color": "$secondaryHex"
          },
          {
            "type": "left_arm",
            "width": ${0.2 * scale},
            "height": ${0.8 * scale},
            "depth": ${1.0 * scale},
            "color": "$primaryHex"
          },
          {
            "type": "right_arm",
            "width": ${0.2 * scale},
            "height": ${0.8 * scale},
            "depth": ${1.0 * scale},
            "color": "$secondaryHex"
          }
        ]
      }
      ''';
    } else if (baseType.contains('chair')) {
      return '''
      {
        "name": "Minecraft Chair",
        "type": "chair",
        "scale": $scale,
        "color": "$primaryHex",
        "components": [
          {
            "type": "seat",
            "width": ${1.0 * scale},
            "height": ${0.2 * scale},
            "depth": ${1.0 * scale},
            "color": "$primaryHex"
          },
          {
            "type": "back",
            "width": ${1.0 * scale},
            "height": ${1.0 * scale},
            "depth": ${0.2 * scale},
            "color": "$primaryHex"
          },
          {
            "type": "leg",
            "width": ${0.1 * scale},
            "height": ${0.8 * scale},
            "depth": ${0.1 * scale},
            "color": "$primaryHex"
          }
        ]
      }
      ''';
    }
    
    return _generateGenericModel(baseType, size, primaryColor, secondaryColor);
  }

  String _generateArmorModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    final colorHex = _colorToHex(primaryColor);
    
    return '''
    {
      "name": "Minecraft Armor",
      "type": "armor",
      "scale": $scale,
      "color": "$colorHex",
      "hasGlow": $hasGlow,
      "components": [
        {
          "type": "helmet",
          "width": ${0.8 * scale},
          "height": ${0.8 * scale},
          "depth": ${0.8 * scale},
          "color": "$colorHex"
        },
        {
          "type": "chestplate",
          "width": ${1.2 * scale},
          "height": ${1.6 * scale},
          "depth": ${0.6 * scale},
          "color": "$colorHex"
        }
      ]
    }
    ''';
  }

  String _generateToolModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    final colorHex = _colorToHex(primaryColor);
    
    return '''
    {
      "name": "Minecraft Tool",
      "type": "tool",
      "scale": $scale,
      "color": "$colorHex",
      "hasGlow": $hasGlow,
      "components": [
        {
          "type": "head",
          "width": ${0.3 * scale},
          "height": ${0.3 * scale},
          "depth": ${0.3 * scale},
          "color": "$colorHex"
        },
        {
          "type": "handle",
          "width": ${0.1 * scale},
          "height": ${1.2 * scale},
          "depth": ${0.1 * scale},
          "color": "#8B4513"
        }
      ]
    }
    ''';
  }

  String _generateGenericModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    final primaryHex = _colorToHex(primaryColor);
    final secondaryHex = _colorToHex(secondaryColor);
    
    return '''
    {
      "name": "Minecraft $baseType",
      "type": "generic",
      "scale": $scale,
      "primaryColor": "$primaryHex",
      "secondaryColor": "$secondaryHex",
      "components": [
        {
          "type": "main",
          "width": ${1.0 * scale},
          "height": ${1.0 * scale},
          "depth": ${1.0 * scale},
          "color": "$primaryHex"
        }
      ]
    }
    ''';
  }

  double _getSizeScale(CreatureSize size) {
    switch (size) {
      case CreatureSize.tiny:
        return 0.5;
      case CreatureSize.small:
        return 0.75;
      case CreatureSize.medium:
        return 1.0;
      case CreatureSize.large:
        return 1.5;
      case CreatureSize.giant:
        return 2.0;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _applyMaterials() {
    // Apply materials based on creature attributes
    final primaryColor = widget.creatureAttributes.primaryColor;
    final secondaryColor = widget.creatureAttributes.secondaryColor;
    
    // Set material properties
    _controller.setMaterialProperties(
      diffuseColor: primaryColor,
      specularColor: secondaryColor,
      emissiveColor: widget.creatureAttributes.glowEffect != GlowEffect.none 
          ? primaryColor.withOpacity(0.3) 
          : Colors.transparent,
    );
  }

  void _applyEffects() {
    // Apply effects based on creature attributes
    if (widget.creatureAttributes.glowEffect != GlowEffect.none) {
      _controller.enableGlow(true);
    }
    
    if (widget.creatureAttributes.glowEffect == GlowEffect.flames) {
      _controller.enableFlames(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.black,
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
        child: _build3DContent(),
      ),
    );
  }

  Widget _build3DContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Loading 3D Model...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '3D Preview Error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load3DModel,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.enableRotation ? _rotationAnimation.value : 0,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Flutter3DViewer(
                  controller: _controller,
                  width: widget.size,
                  height: widget.size,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
