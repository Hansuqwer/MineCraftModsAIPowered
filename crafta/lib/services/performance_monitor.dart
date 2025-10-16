import 'dart:async';
import 'dart:developer' as developer;

/// Performance monitoring service for tracking app performance
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  /// Performance metrics storage
  final Map<String, List<Duration>> _metrics = {};
  final Map<String, int> _eventCounts = {};
  final Map<String, DateTime> _startTimes = {};

  /// Memory tracking
  int _lastMemoryCheck = 0;
  final List<int> _memoryReadings = [];

  /// Start timing an operation
  void startOperation(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End timing an operation
  void endOperation(String operationName) {
    if (!_startTimes.containsKey(operationName)) {
      print('⚠️ Warning: No start time found for $operationName');
      return;
    }

    final duration = DateTime.now().difference(_startTimes[operationName]!);
    _startTimes.remove(operationName);

    // Store metric
    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }
    _metrics[operationName]!.add(duration);

    // Log if slow
    if (duration.inMilliseconds > 1000) {
      print('🐌 Slow operation: $operationName took ${duration.inMilliseconds}ms');
    }
  }

  /// Track an event
  void trackEvent(String eventName) {
    _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;
  }

  /// Measure execution time of a function
  Future<T> measureAsync<T>(String operationName, Future<T> Function() operation) async {
    startOperation(operationName);
    try {
      return await operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Measure execution time of a synchronous function
  T measureSync<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      return operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Get average time for an operation
  Duration? getAverageTime(String operationName) {
    if (!_metrics.containsKey(operationName) || _metrics[operationName]!.isEmpty) {
      return null;
    }

    final durations = _metrics[operationName]!;
    final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get minimum time for an operation
  Duration? getMinTime(String operationName) {
    if (!_metrics.containsKey(operationName) || _metrics[operationName]!.isEmpty) {
      return null;
    }

    return _metrics[operationName]!.reduce((a, b) => a < b ? a : b);
  }

  /// Get maximum time for an operation
  Duration? getMaxTime(String operationName) {
    if (!_metrics.containsKey(operationName) || _metrics[operationName]!.isEmpty) {
      return null;
    }

    return _metrics[operationName]!.reduce((a, b) => a > b ? a : b);
  }

  /// Get percentile time for an operation
  Duration? getPercentile(String operationName, double percentile) {
    if (!_metrics.containsKey(operationName) || _metrics[operationName]!.isEmpty) {
      return null;
    }

    final durations = List<Duration>.from(_metrics[operationName]!);
    durations.sort((a, b) => a.compareTo(b));

    final index = ((durations.length - 1) * percentile).round();
    return durations[index];
  }

  /// Get performance statistics for an operation
  Map<String, dynamic> getStats(String operationName) {
    if (!_metrics.containsKey(operationName) || _metrics[operationName]!.isEmpty) {
      return {
        'count': 0,
        'average': null,
        'min': null,
        'max': null,
        'p50': null,
        'p95': null,
        'p99': null,
      };
    }

    return {
      'count': _metrics[operationName]!.length,
      'average': getAverageTime(operationName)?.inMilliseconds,
      'min': getMinTime(operationName)?.inMilliseconds,
      'max': getMaxTime(operationName)?.inMilliseconds,
      'p50': getPercentile(operationName, 0.50)?.inMilliseconds,
      'p95': getPercentile(operationName, 0.95)?.inMilliseconds,
      'p99': getPercentile(operationName, 0.99)?.inMilliseconds,
    };
  }

  /// Get all metrics
  Map<String, Map<String, dynamic>> getAllStats() {
    final allStats = <String, Map<String, dynamic>>{};
    for (final operation in _metrics.keys) {
      allStats[operation] = getStats(operation);
    }
    return allStats;
  }

  /// Get event counts
  Map<String, int> getEventCounts() {
    return Map.unmodifiable(_eventCounts);
  }

  /// Check current memory usage (approximate)
  void checkMemory(String checkpoint) {
    // Note: Dart doesn't provide direct memory API
    // This is a placeholder for memory tracking
    developer.Timeline.startSync('memory_check');
    _memoryReadings.add(DateTime.now().millisecondsSinceEpoch);
    developer.Timeline.finishSync();

    trackEvent('memory_check_$checkpoint');
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _eventCounts.clear();
    _startTimes.clear();
    _memoryReadings.clear();
  }

  /// Clear metrics for a specific operation
  void clearOperation(String operationName) {
    _metrics.remove(operationName);
    _startTimes.remove(operationName);
  }

  /// Get summary report
  String getSummaryReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Performance Summary Report');
    buffer.writeln('=' * 50);

    if (_metrics.isEmpty) {
      buffer.writeln('No metrics recorded');
      return buffer.toString();
    }

    // Operations
    buffer.writeln('\n🎯 Operations:');
    for (final operation in _metrics.keys) {
      final stats = getStats(operation);
      buffer.writeln('  $operation:');
      buffer.writeln('    Count: ${stats['count']}');
      buffer.writeln('    Avg: ${stats['average']}ms');
      buffer.writeln('    Min: ${stats['min']}ms');
      buffer.writeln('    Max: ${stats['max']}ms');
      buffer.writeln('    P95: ${stats['p95']}ms');
    }

    // Events
    if (_eventCounts.isNotEmpty) {
      buffer.writeln('\n📈 Events:');
      for (final event in _eventCounts.entries) {
        buffer.writeln('  ${event.key}: ${event.value}');
      }
    }

    // Performance warnings
    buffer.writeln('\n⚠️  Performance Warnings:');
    var hasWarnings = false;
    for (final operation in _metrics.keys) {
      final stats = getStats(operation);
      if (stats['average'] != null && stats['average'] > 1000) {
        buffer.writeln('  ⚠️  $operation average time is ${stats['average']}ms (>1s)');
        hasWarnings = true;
      }
      if (stats['p95'] != null && stats['p95'] > 2000) {
        buffer.writeln('  ⚠️  $operation P95 is ${stats['p95']}ms (>2s)');
        hasWarnings = true;
      }
    }
    if (!hasWarnings) {
      buffer.writeln('  ✅ No performance warnings');
    }

    return buffer.toString();
  }

  /// Export metrics as JSON
  Map<String, dynamic> exportMetrics() {
    return {
      'metrics': getAllStats(),
      'events': getEventCounts(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Check if operation is slow
  bool isOperationSlow(String operationName, {int thresholdMs = 1000}) {
    final avg = getAverageTime(operationName);
    return avg != null && avg.inMilliseconds > thresholdMs;
  }

  /// Get slow operations
  List<String> getSlowOperations({int thresholdMs = 1000}) {
    return _metrics.keys.where((op) => isOperationSlow(op, thresholdMs: thresholdMs)).toList();
  }
}

/// Extension for easy performance tracking
extension PerformanceExtension on Future {
  /// Measure the performance of this future
  Future<T> measure<T>(String operationName) async {
    return PerformanceMonitor().measureAsync(operationName, () => this as Future<T>);
  }
}
