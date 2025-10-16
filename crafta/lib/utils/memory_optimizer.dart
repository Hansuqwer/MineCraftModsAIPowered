import 'dart:async';
import 'dart:collection';

/// Memory optimization utilities for the app
class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  factory MemoryOptimizer() => _instance;
  MemoryOptimizer._internal();

  /// Conversation message limit
  static const int MAX_CONVERSATION_MESSAGES = 50;

  /// Cache size limits
  static const int MAX_CACHE_SIZE = 100;
  static const Duration CACHE_CLEANUP_INTERVAL = Duration(minutes: 5);

  /// Timer for periodic cleanup
  Timer? _cleanupTimer;

  /// LRU Cache implementation
  final _caches = <String, LRUCache>{};

  /// Start periodic memory cleanup
  void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(CACHE_CLEANUP_INTERVAL, (_) {
      performCleanup();
    });
  }

  /// Stop periodic cleanup
  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Perform memory cleanup
  void performCleanup() {
    print('🧹 Performing memory cleanup...');

    // Clean up caches
    for (final cache in _caches.values) {
      cache.removeExpired();
    }

    // Log cleanup
    print('✅ Memory cleanup complete');
  }

  /// Get or create cache
  LRUCache<String, T> getCache<T>(String name, {int maxSize = MAX_CACHE_SIZE}) {
    if (!_caches.containsKey(name)) {
      _caches[name] = LRUCache<String, T>(maxSize: maxSize);
    }
    return _caches[name] as LRUCache<String, T>;
  }

  /// Clear all caches
  void clearAllCaches() {
    for (final cache in _caches.values) {
      cache.clear();
    }
    print('🗑️  All caches cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final stats = <String, dynamic>{};
    for (final entry in _caches.entries) {
      stats[entry.key] = {
        'size': entry.value.size,
        'maxSize': entry.value.maxSize,
        'hitRate': entry.value.hitRate,
      };
    }
    return stats;
  }

  /// Trim conversation history
  List<T> trimList<T>(List<T> list, {int maxItems = MAX_CONVERSATION_MESSAGES}) {
    if (list.length <= maxItems) {
      return list;
    }
    return list.sublist(list.length - maxItems);
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicCleanup();
    clearAllCaches();
  }
}

/// LRU (Least Recently Used) Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, CacheEntry<V>>();
  int _hits = 0;
  int _misses = 0;

  LRUCache({this.maxSize = 100});

  /// Get value from cache
  V? get(K key) {
    if (!_cache.containsKey(key)) {
      _misses++;
      return null;
    }

    final entry = _cache.remove(key)!;

    // Check if expired
    if (entry.isExpired) {
      _misses++;
      return null;
    }

    // Move to end (most recently used)
    _cache[key] = entry;
    _hits++;

    return entry.value;
  }

  /// Put value in cache
  void put(K key, V value, {Duration? ttl}) {
    // Remove if exists
    _cache.remove(key);

    // Add to end
    _cache[key] = CacheEntry(value, ttl: ttl);

    // Evict oldest if over limit
    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Check if key exists
  bool containsKey(K key) {
    if (!_cache.containsKey(key)) {
      return false;
    }

    final entry = _cache[key]!;
    return !entry.isExpired;
  }

  /// Remove entry
  V? remove(K key) {
    final entry = _cache.remove(key);
    return entry?.value;
  }

  /// Clear cache
  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  /// Remove expired entries
  void removeExpired() {
    final keysToRemove = <K>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('🗑️  Removed ${keysToRemove.length} expired cache entries');
    }
  }

  /// Get current size
  int get size => _cache.length;

  /// Get hit rate
  double get hitRate {
    final total = _hits + _misses;
    return total == 0 ? 0.0 : _hits / total;
  }

  /// Get cache statistics
  Map<String, dynamic> get stats => {
        'size': size,
        'maxSize': maxSize,
        'hits': _hits,
        'misses': _misses,
        'hitRate': hitRate,
      };
}

/// Cache entry with TTL support
class CacheEntry<V> {
  final V value;
  final DateTime createdAt;
  final Duration? ttl;

  CacheEntry(this.value, {this.ttl}) : createdAt = DateTime.now();

  /// Check if entry is expired
  bool get isExpired {
    if (ttl == null) {
      return false;
    }

    return DateTime.now().difference(createdAt) > ttl!;
  }
}

/// Memory-efficient list wrapper
class BoundedList<T> {
  final int maxSize;
  final List<T> _list = [];

  BoundedList(this.maxSize);

  /// Add item (removes oldest if at capacity)
  void add(T item) {
    if (_list.length >= maxSize) {
      _list.removeAt(0);
    }
    _list.add(item);
  }

  /// Add all items
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Get item at index
  T operator [](int index) => _list[index];

  /// Get length
  int get length => _list.length;

  /// Check if empty
  bool get isEmpty => _list.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _list.isNotEmpty;

  /// Clear list
  void clear() => _list.clear();

  /// Get as regular list
  List<T> toList() => List.unmodifiable(_list);

  /// Remove item
  bool remove(T item) => _list.remove(item);

  /// Remove at index
  T removeAt(int index) => _list.removeAt(index);
}

/// Image cache for optimizing image loading
class ImageCache {
  static final ImageCache _instance = ImageCache._internal();
  factory ImageCache() => _instance;
  ImageCache._internal();

  final _cache = LRUCache<String, dynamic>(maxSize: 50);

  /// Cache image
  void cacheImage(String key, dynamic image) {
    _cache.put(key, image, ttl: const Duration(hours: 1));
  }

  /// Get cached image
  dynamic getImage(String key) {
    return _cache.get(key);
  }

  /// Clear image cache
  void clear() {
    _cache.clear();
    print('🗑️  Image cache cleared');
  }

  /// Get cache size
  int get size => _cache.size;
}
