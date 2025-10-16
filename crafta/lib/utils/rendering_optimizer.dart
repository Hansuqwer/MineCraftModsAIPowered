import 'dart:ui';
import 'package:vector_math/vector_math.dart';

/// 3D Rendering optimization utilities
class RenderingOptimizer {
  static final RenderingOptimizer _instance = RenderingOptimizer._internal();
  factory RenderingOptimizer() => _instance;
  RenderingOptimizer._internal();

  /// Frame rate tracking
  final List<Duration> _frameTimes = [];
  static const int MAX_FRAME_SAMPLES = 60;

  /// LOD (Level of Detail) settings
  static const double HIGH_DETAIL_DISTANCE = 5.0;
  static const double MEDIUM_DETAIL_DISTANCE = 15.0;
  static const double LOW_DETAIL_DISTANCE = 30.0;

  /// Maximum simultaneous particles
  static const int MAX_PARTICLES = 100;

  /// Track frame time
  void trackFrame(Duration frameTime) {
    _frameTimes.add(frameTime);
    if (_frameTimes.length > MAX_FRAME_SAMPLES) {
      _frameTimes.removeAt(0);
    }
  }

  /// Get current FPS
  double get currentFPS {
    if (_frameTimes.isEmpty) {
      return 0.0;
    }

    final avgFrameTime = _frameTimes.fold<int>(
          0,
          (sum, time) => sum + time.inMicroseconds,
        ) /
        _frameTimes.length;

    return avgFrameTime > 0 ? 1000000.0 / avgFrameTime : 0.0;
  }

  /// Check if FPS is acceptable
  bool get isPerformanceGood => currentFPS >= 30.0;

  /// Get LOD level based on distance
  LODLevel getLODLevel(double distance) {
    if (distance < HIGH_DETAIL_DISTANCE) {
      return LODLevel.high;
    } else if (distance < MEDIUM_DETAIL_DISTANCE) {
      return LODLevel.medium;
    } else if (distance < LOW_DETAIL_DISTANCE) {
      return LODLevel.low;
    } else {
      return LODLevel.culled;
    }
  }

  /// Get mesh complexity for LOD level
  int getMeshComplexity(LODLevel level) {
    switch (level) {
      case LODLevel.high:
        return 1000; // vertices
      case LODLevel.medium:
        return 500;
      case LODLevel.low:
        return 200;
      case LODLevel.culled:
        return 0;
    }
  }

  /// Optimize particle count based on performance
  int getOptimalParticleCount(int desired) {
    if (isPerformanceGood) {
      return desired.clamp(0, MAX_PARTICLES);
    } else {
      // Reduce particles if performance is poor
      return (desired * 0.5).round().clamp(0, MAX_PARTICLES ~/ 2);
    }
  }

  /// Check if object should be rendered (frustum culling)
  bool shouldRender(Vector3 position, double radius, Matrix4 viewProjection) {
    // Simple sphere culling
    // In production, implement proper frustum culling
    final distance = position.length;
    return distance < (LOW_DETAIL_DISTANCE + radius);
  }

  /// Optimize mesh for performance
  OptimizedMesh optimizeMesh(List<Vector3> vertices, List<int> indices) {
    final lodLevel = isPerformanceGood ? LODLevel.high : LODLevel.medium;
    final targetComplexity = getMeshComplexity(lodLevel);

    // If vertices are within target, return as-is
    if (vertices.length <= targetComplexity) {
      return OptimizedMesh(vertices, indices, lodLevel);
    }

    // Simplify mesh (basic decimation)
    final step = (vertices.length / targetComplexity).ceil();
    final optimizedVertices = <Vector3>[];
    final optimizedIndices = <int>[];

    for (var i = 0; i < vertices.length; i += step) {
      optimizedVertices.add(vertices[i]);
    }

    // Rebuild indices (simplified triangulation)
    for (var i = 0; i < optimizedVertices.length - 2; i++) {
      optimizedIndices.addAll([i, i + 1, i + 2]);
    }

    return OptimizedMesh(optimizedVertices, optimizedIndices, lodLevel);
  }

  /// Get rendering quality recommendation
  RenderQuality getRecommendedQuality() {
    final fps = currentFPS;

    if (fps >= 55) {
      return RenderQuality.high;
    } else if (fps >= 40) {
      return RenderQuality.medium;
    } else if (fps >= 25) {
      return RenderQuality.low;
    } else {
      return RenderQuality.minimal;
    }
  }

  /// Apply quality settings
  QualitySettings applyQuality(RenderQuality quality) {
    switch (quality) {
      case RenderQuality.high:
        return QualitySettings(
          enableShadows: true,
          enableParticles: true,
          particleCount: MAX_PARTICLES,
          enableGlow: true,
          enableReflections: true,
          meshQuality: LODLevel.high,
        );

      case RenderQuality.medium:
        return QualitySettings(
          enableShadows: true,
          enableParticles: true,
          particleCount: MAX_PARTICLES ~/ 2,
          enableGlow: true,
          enableReflections: false,
          meshQuality: LODLevel.medium,
        );

      case RenderQuality.low:
        return QualitySettings(
          enableShadows: false,
          enableParticles: true,
          particleCount: MAX_PARTICLES ~/ 4,
          enableGlow: false,
          enableReflections: false,
          meshQuality: LODLevel.low,
        );

      case RenderQuality.minimal:
        return QualitySettings(
          enableShadows: false,
          enableParticles: false,
          particleCount: 0,
          enableGlow: false,
          enableReflections: false,
          meshQuality: LODLevel.low,
        );
    }
  }

  /// Batch render calls
  List<RenderBatch> batchRenderCalls(List<RenderCall> calls) {
    final batches = <String, RenderBatch>{};

    for (final call in calls) {
      final key = '${call.materialType}_${call.textureId}';

      if (!batches.containsKey(key)) {
        batches[key] = RenderBatch(call.materialType, call.textureId);
      }

      batches[key]!.calls.add(call);
    }

    return batches.values.toList();
  }

  /// Clear frame tracking
  void clearFrameTracking() {
    _frameTimes.clear();
  }

  /// Get performance statistics
  Map<String, dynamic> getStats() {
    return {
      'fps': currentFPS.toStringAsFixed(1),
      'avgFrameTime': _frameTimes.isEmpty
          ? '0ms'
          : '${(_frameTimes.fold<int>(0, (sum, t) => sum + t.inMicroseconds) / _frameTimes.length / 1000).toStringAsFixed(2)}ms',
      'samples': _frameTimes.length,
      'performanceGood': isPerformanceGood,
      'recommendedQuality': getRecommendedQuality().name,
    };
  }
}

/// Level of Detail enum
enum LODLevel {
  high,
  medium,
  low,
  culled,
}

/// Render quality levels
enum RenderQuality {
  high,
  medium,
  low,
  minimal,
}

/// Optimized mesh data
class OptimizedMesh {
  final List<Vector3> vertices;
  final List<int> indices;
  final LODLevel lodLevel;

  OptimizedMesh(this.vertices, this.indices, this.lodLevel);

  int get vertexCount => vertices.length;
  int get triangleCount => indices.length ~/ 3;
}

/// Quality settings
class QualitySettings {
  final bool enableShadows;
  final bool enableParticles;
  final int particleCount;
  final bool enableGlow;
  final bool enableReflections;
  final LODLevel meshQuality;

  QualitySettings({
    required this.enableShadows,
    required this.enableParticles,
    required this.particleCount,
    required this.enableGlow,
    required this.enableReflections,
    required this.meshQuality,
  });
}

/// Render call for batching
class RenderCall {
  final String materialType;
  final String textureId;
  final Matrix4 transform;
  final List<Vector3> vertices;

  RenderCall({
    required this.materialType,
    required this.textureId,
    required this.transform,
    required this.vertices,
  });
}

/// Batch of similar render calls
class RenderBatch {
  final String materialType;
  final String textureId;
  final List<RenderCall> calls = [];

  RenderBatch(this.materialType, this.textureId);

  int get callCount => calls.length;
}

/// Particle system optimizer
class ParticleOptimizer {
  /// Pool of reusable particles
  final List<Particle> _particlePool = [];
  final List<Particle> _activeParticles = [];

  /// Get particle from pool
  Particle getParticle() {
    if (_particlePool.isNotEmpty) {
      final particle = _particlePool.removeLast();
      _activeParticles.add(particle);
      return particle;
    }

    final newParticle = Particle();
    _activeParticles.add(newParticle);
    return newParticle;
  }

  /// Return particle to pool
  void returnParticle(Particle particle) {
    _activeParticles.remove(particle);
    if (_particlePool.length < RenderingOptimizer.MAX_PARTICLES) {
      particle.reset();
      _particlePool.add(particle);
    }
  }

  /// Update all particles
  void update(Duration deltaTime) {
    final toRemove = <Particle>[];

    for (final particle in _activeParticles) {
      particle.update(deltaTime);

      if (!particle.isAlive) {
        toRemove.add(particle);
      }
    }

    for (final particle in toRemove) {
      returnParticle(particle);
    }
  }

  /// Clear all particles
  void clear() {
    _particlePool.addAll(_activeParticles);
    _activeParticles.clear();
  }

  /// Get particle count
  int get activeCount => _activeParticles.length;
  int get poolSize => _particlePool.length;
}

/// Particle class
class Particle {
  Vector3 position = Vector3.zero();
  Vector3 velocity = Vector3.zero();
  Color color = const Color(0xFFFFFFFF);
  double size = 1.0;
  double life = 1.0;
  double age = 0.0;

  bool get isAlive => age < life;

  void update(Duration deltaTime) {
    final dt = deltaTime.inMicroseconds / 1000000.0;
    age += dt;

    position.add(velocity * dt);
  }

  void reset() {
    position = Vector3.zero();
    velocity = Vector3.zero();
    color = const Color(0xFFFFFFFF);
    size = 1.0;
    life = 1.0;
    age = 0.0;
  }
}
