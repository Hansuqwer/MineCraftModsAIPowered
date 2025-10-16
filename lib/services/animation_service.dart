import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animation Service for Creature Effects
/// Handles advanced animations and visual effects
class AnimationService {
  static const Duration _defaultDuration = Duration(seconds: 2);
  static const Curve _defaultCurve = Curves.easeInOut;
  
  /// Create rotation animation
  static AnimationController createRotationAnimation({
    required TickerProvider vsync,
    Duration duration = _defaultDuration,
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create floating animation
  static AnimationController createFloatingAnimation({
    required TickerProvider vsync,
    Duration duration = _defaultDuration,
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create pulse animation
  static AnimationController createPulseAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create bounce animation
  static AnimationController createBounceAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create sparkle animation
  static AnimationController createSparkleAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create fire animation
  static AnimationController createFireAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create lightning animation
  static AnimationController createLightningAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 200),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create magic animation
  static AnimationController createMagicAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create rainbow animation
  static AnimationController createRainbowAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 4),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create glow animation
  static AnimationController createGlowAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create shimmer animation
  static AnimationController createShimmerAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create glitter animation
  static AnimationController createGlitterAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create interaction animation
  static AnimationController createInteractionAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create celebration animation
  static AnimationController createCelebrationAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Get animation curve for effect
  static Curve getCurveForEffect(String effect) {
    switch (effect.toLowerCase()) {
      case 'sparkles':
        return Curves.easeInOut;
      case 'fire':
        return Curves.linear;
      case 'ice':
        return Curves.easeInOut;
      case 'lightning':
        return Curves.elasticOut;
      case 'magic':
        return Curves.easeInOut;
      case 'rainbow':
        return Curves.easeInOut;
      case 'glow':
        return Curves.easeInOut;
      case 'shimmer':
        return Curves.easeInOut;
      case 'glitter':
        return Curves.easeInOut;
      default:
        return Curves.easeInOut;
    }
  }
  
  /// Get animation duration for effect
  static Duration getDurationForEffect(String effect) {
    switch (effect.toLowerCase()) {
      case 'sparkles':
        return const Duration(seconds: 3);
      case 'fire':
        return const Duration(milliseconds: 500);
      case 'ice':
        return const Duration(seconds: 2);
      case 'lightning':
        return const Duration(milliseconds: 200);
      case 'magic':
        return const Duration(seconds: 2);
      case 'rainbow':
        return const Duration(seconds: 4);
      case 'glow':
        return const Duration(seconds: 2);
      case 'shimmer':
        return const Duration(seconds: 2);
      case 'glitter':
        return const Duration(seconds: 3);
      default:
        return const Duration(seconds: 2);
    }
  }
  
  /// Create complex animation sequence
  static List<AnimationController> createAnimationSequence({
    required TickerProvider vsync,
    required List<String> effects,
  }) {
    final controllers = <AnimationController>[];
    
    for (final effect in effects) {
      final duration = getDurationForEffect(effect);
      final controller = AnimationController(
        duration: duration,
        vsync: vsync,
      );
      
      switch (effect.toLowerCase()) {
        case 'sparkles':
          controller.repeat();
          break;
        case 'fire':
          controller.repeat();
          break;
        case 'ice':
          controller.repeat(reverse: true);
          break;
        case 'lightning':
          controller.repeat();
          break;
        case 'magic':
          controller.repeat();
          break;
        case 'rainbow':
          controller.repeat();
          break;
        case 'glow':
          controller.repeat(reverse: true);
          break;
        case 'shimmer':
          controller.repeat();
          break;
        case 'glitter':
          controller.repeat();
          break;
        default:
          controller.repeat(reverse: true);
      }
      
      controllers.add(controller);
    }
    
    return controllers;
  }
  
  /// Create staggered animation
  static AnimationController createStaggeredAnimation({
    required TickerProvider vsync,
    required int index,
    required int total,
    Duration baseDuration = _defaultDuration,
  }) {
    final delay = (index * 100).clamp(0, 1000);
    final duration = Duration(
      milliseconds: baseDuration.inMilliseconds + delay,
    );
    
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create wave animation
  static AnimationController createWaveAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create spiral animation
  static AnimationController createSpiralAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create orbit animation
  static AnimationController createOrbitAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 4),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create breathing animation
  static AnimationController createBreathingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create heartbeat animation
  static AnimationController createHeartbeatAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create explosion animation
  static AnimationController createExplosionAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create implosion animation
  static AnimationController createImplosionAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create morphing animation
  static AnimationController createMorphingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create teleportation animation
  static AnimationController createTeleportationAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1000),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create transformation animation
  static AnimationController createTransformationAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    return controller;
  }
  
  /// Create levitation animation
  static AnimationController createLevitationAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create hovering animation
  static AnimationController createHoveringAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create flying animation
  static AnimationController createFlyingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create swimming animation
  static AnimationController createSwimmingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create running animation
  static AnimationController createRunningAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create jumping animation
  static AnimationController createJumpingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create climbing animation
  static AnimationController createClimbingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create digging animation
  static AnimationController createDiggingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1200),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create singing animation
  static AnimationController createSingingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 2),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Create dancing animation
  static AnimationController createDancingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create teleporting animation
  static AnimationController createTeleportingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat();
    }
    
    return controller;
  }
  
  /// Create transforming animation
  static AnimationController createTransformingAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 3),
    bool repeat = true,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (repeat) {
      controller.repeat(reverse: true);
    }
    
    return controller;
  }
  
  /// Get all available animations
  static List<String> getAvailableAnimations() {
    return [
      'rotation', 'floating', 'pulse', 'bounce', 'sparkle', 'fire', 'ice',
      'lightning', 'magic', 'rainbow', 'glow', 'shimmer', 'glitter',
      'interaction', 'celebration', 'staggered', 'wave', 'spiral', 'orbit',
      'breathing', 'heartbeat', 'explosion', 'implosion', 'morphing',
      'teleportation', 'transformation', 'levitation', 'hovering', 'flying',
      'swimming', 'running', 'jumping', 'climbing', 'digging', 'singing',
      'dancing', 'teleporting', 'transforming'
    ];
  }
  
  /// Get animations for creature type
  static List<String> getAnimationsForCreature(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'dragon':
        return ['flying', 'fire', 'breathing', 'hovering'];
      case 'unicorn':
        return ['galloping', 'sparkle', 'magic', 'transformation'];
      case 'phoenix':
        return ['flying', 'fire', 'transformation', 'explosion'];
      case 'griffin':
        return ['flying', 'hovering', 'gliding', 'landing'];
      case 'sword':
        return ['glow', 'sparkle', 'magic', 'pulse'];
      case 'wand':
        return ['sparkle', 'magic', 'glow', 'pulse'];
      case 'bow':
        return ['glow', 'sparkle', 'magic', 'pulse'];
      case 'shield':
        return ['glow', 'sparkle', 'magic', 'pulse'];
      case 'hammer':
        return ['glow', 'sparkle', 'magic', 'pulse'];
      default:
        return ['pulse', 'bounce', 'floating', 'rotation'];
    }
  }
  
  /// Get animations for effect
  static List<String> getAnimationsForEffect(String effect) {
    switch (effect.toLowerCase()) {
      case 'sparkles':
        return ['sparkle', 'glitter', 'shimmer'];
      case 'fire':
        return ['fire', 'explosion', 'breathing'];
      case 'ice':
        return ['ice', 'freeze', 'crystal'];
      case 'lightning':
        return ['lightning', 'electric', 'spark'];
      case 'magic':
        return ['magic', 'sparkle', 'glow'];
      case 'rainbow':
        return ['rainbow', 'color', 'spectrum'];
      case 'glow':
        return ['glow', 'pulse', 'breathing'];
      case 'shimmer':
        return ['shimmer', 'sparkle', 'glitter'];
      case 'glitter':
        return ['glitter', 'sparkle', 'shimmer'];
      default:
        return ['pulse', 'bounce', 'floating'];
    }
  }
}
