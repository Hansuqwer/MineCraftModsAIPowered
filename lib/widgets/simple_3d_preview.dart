import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/enhanced_creature_attributes.dart';

/// Simple 3D Preview Widget
/// Uses Flutter's built-in 3D transforms for mobile-optimized rendering
class Simple3DPreview extends StatefulWidget {
  final EnhancedCreatureAttributes creatureAttributes;
  final String creatureName;
  final double size;
  final bool enableRotation;
  final bool enableZoom;
  final bool enableEffects;

  const Simple3DPreview({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
    this.size = 300.0,
    this.enableRotation = true,
    this.enableZoom = true,
    this.enableEffects = true,
  });

  @override
  State<Simple3DPreview> createState() => _Simple3DPreviewState();
}

class _Simple3DPreviewState extends State<Simple3DPreview>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
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
    if (widget.enableRotation) {
      _rotationController.repeat();
    }
    _scaleController.forward();
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
                child: _buildModel(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModel() {
    final baseType = widget.creatureAttributes.baseType.toLowerCase();
    final size = widget.creatureAttributes.size;
    final primaryColor = widget.creatureAttributes.primaryColor;
    final secondaryColor = widget.creatureAttributes.secondaryColor;
    final hasWings = widget.creatureAttributes.abilities.contains(SpecialAbility.flying);
    final hasFlames = widget.creatureAttributes.glowEffect == GlowEffect.flames;
    final hasGlow = widget.creatureAttributes.glowEffect != GlowEffect.none;

    // Generate model based on type
    if (baseType.contains('sword') || baseType.contains('weapon')) {
      return _buildSwordModel(size, primaryColor, hasFlames, hasGlow);
    } else if (baseType.contains('dragon') || baseType.contains('creature')) {
      return _buildDragonModel(size, primaryColor, secondaryColor, hasWings, hasFlames);
    } else if (baseType.contains('furniture') || baseType.contains('chair') || baseType.contains('couch')) {
      return _buildFurnitureModel(baseType, size, primaryColor, secondaryColor);
    } else if (baseType.contains('armor') || baseType.contains('helmet')) {
      return _buildArmorModel(baseType, size, primaryColor, hasGlow);
    } else if (baseType.contains('tool') || baseType.contains('pickaxe')) {
      return _buildToolModel(baseType, size, primaryColor, hasGlow);
    } else {
      return _buildGenericModel(baseType, size, primaryColor, secondaryColor);
    }
  }

  Widget _buildSwordModel(CreatureSize size, Color primaryColor, bool hasFlames, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sword blade
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -scale * 40)
            ..scale(scale),
          child: Container(
            width: 8,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Sword handle
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, scale * 20)
            ..scale(scale),
          child: Container(
            width: 12,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513), // Brown
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        // Sword guard
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -scale * 10)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Flame effect
        if (hasFlames)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0.0, -scale * 60)
              ..scale(scale),
            child: Container(
              width: 16,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.red],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDragonModel(CreatureSize size, Color primaryColor, Color secondaryColor, bool hasWings, bool hasFlames) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dragon body
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        // Dragon head
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(-scale * 25, -scale * 15)
            ..scale(scale),
          child: Container(
            width: 30,
            height: 25,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        // Dragon tail
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(scale * 30, scale * 10)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 30,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Wings
        if (hasWings) ...[
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * 20, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(scale * 20, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
        // Flame effect
        if (hasFlames)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * 35, -scale * 20)
              ..scale(scale),
            child: Container(
              width: 15,
              height: 25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.red],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFurnitureModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    if (baseType.contains('couch') || baseType.contains('sofa')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Couch seat
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale),
            child: Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Couch back
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0, -scale * 15)
              ..scale(scale),
            child: Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Left arm
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-scale * 35, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 15,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Right arm
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(scale * 35, -scale * 5)
              ..scale(scale),
            child: Container(
              width: 15,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    } else if (baseType.contains('chair')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Chair seat
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale),
            child: Container(
              width: 40,
              height: 15,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Chair back
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0, -scale * 20)
              ..scale(scale),
            child: Container(
              width: 40,
              height: 25,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Chair legs
          ...List.generate(4, (index) {
            final angle = (index * math.pi / 2);
            final x = math.cos(angle) * 15;
            final y = math.sin(angle) * 15;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(x * scale, y * scale + scale * 10)
                ..scale(scale),
              child: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ],
      );
    }
    
    return _buildGenericModel(baseType, size, primaryColor, secondaryColor);
  }

  Widget _buildArmorModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Helmet
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Chestplate
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolModel(String baseType, CreatureSize size, Color primaryColor, bool hasGlow) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Tool head
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: hasGlow ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
        // Tool handle
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, scale * 15)
            ..scale(scale),
          child: Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513), // Brown
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericModel(String baseType, CreatureSize size, Color primaryColor, Color secondaryColor) {
    final scale = _getSizeScale(size);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main body
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        // Secondary details
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0, -scale * 20)
            ..scale(scale),
          child: Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
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
}
