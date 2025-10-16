import 'dart:io';
import 'dart:async';

/// Service to check network connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  /// Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  /// Get connectivity stream
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool _isConnected = true;

  /// Get current connectivity status
  bool get isConnected => _isConnected;

  /// Check if device has internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      // Try to lookup a reliable host
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _connectivityController.add(_isConnected);

      return _isConnected;
    } on SocketException catch (_) {
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    } on TimeoutException catch (_) {
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    } catch (e) {
      print('Connectivity check error: $e');
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    }
  }

  /// Start periodic connectivity checks
  Timer? _periodicTimer;

  void startPeriodicChecks({Duration interval = const Duration(seconds: 30)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => checkConnectivity());
  }

  /// Stop periodic connectivity checks
  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Check connectivity with custom host
  Future<bool> checkHost(String host, {int port = 80}) async {
    try {
      final socket = await Socket.connect(host, port)
          .timeout(const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if OpenAI API is reachable
  Future<bool> checkOpenAIConnectivity() async {
    try {
      final result = await InternetAddress.lookup('api.openai.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _periodicTimer?.cancel();
    _connectivityController.close();
  }

  /// Get connectivity quality (poor, fair, good)
  Future<ConnectivityQuality> getConnectivityQuality() async {
    final stopwatch = Stopwatch()..start();

    try {
      await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      if (latency < 200) {
        return ConnectivityQuality.good;
      } else if (latency < 500) {
        return ConnectivityQuality.fair;
      } else {
        return ConnectivityQuality.poor;
      }
    } catch (e) {
      return ConnectivityQuality.none;
    }
  }

  /// Wait for connectivity to be restored
  Future<bool> waitForConnectivity({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await checkConnectivity()) {
        return true;
      }
      await Future.delayed(checkInterval);
    }

    return false;
  }
}

/// Connectivity quality enum
enum ConnectivityQuality {
  none,   // No connectivity
  poor,   // >500ms latency
  fair,   // 200-500ms latency
  good,   // <200ms latency
}

/// Extension for connectivity quality
extension ConnectivityQualityExtension on ConnectivityQuality {
  /// Get child-friendly message
  String get message {
    switch (this) {
      case ConnectivityQuality.none:
        return 'No internet connection';
      case ConnectivityQuality.poor:
        return 'Slow internet connection';
      case ConnectivityQuality.fair:
        return 'Internet connection is okay';
      case ConnectivityQuality.good:
        return 'Great internet connection!';
    }
  }

  /// Get icon for quality
  String get icon {
    switch (this) {
      case ConnectivityQuality.none:
        return '❌';
      case ConnectivityQuality.poor:
        return '📶';
      case ConnectivityQuality.fair:
        return '📶📶';
      case ConnectivityQuality.good:
        return '📶📶📶';
    }
  }
}
