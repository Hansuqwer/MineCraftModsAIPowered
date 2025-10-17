import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Debug service for remote debugging
class DebugService {
  static const String _debugEndpoint = 'http://192.168.1.100:8080/debug'; // Change to your computer's IP
  static bool _isEnabled = true;
  static final List<DebugLog> _logBuffer = [];
  static const int _maxBufferSize = 100;

  /// Initialize debug service
  static Future<void> initialize() async {
    if (!_isEnabled) return;
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await _sendLog(
        'DEBUG_SERVICE_INIT',
        'Debug service initialized',
        {
          'app_version': packageInfo.version,
          'build_number': packageInfo.buildNumber,
          'package_name': packageInfo.packageName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ Debug service init failed: $e');
    }
  }

  /// Send debug log to remote endpoint
  static Future<void> log(String level, String message, [Map<String, dynamic>? data]) async {
    if (!_isEnabled) return;
    
    final log = DebugLog(
      level: level,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
    
    _logBuffer.add(log);
    
    // Keep buffer size manageable
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }
    
    // Try to send immediately
    await _sendLog(level, message, data);
  }

  /// Send log to remote endpoint
  static Future<void> _sendLog(String level, String message, [Map<String, dynamic>? data]) async {
    try {
      final logData = {
        'level': level,
        'message': message,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'device_info': await _getDeviceInfo(),
      };
      
      final response = await http.post(
        Uri.parse(_debugEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(logData),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('✅ Debug log sent: $level - $message');
      } else {
        print('❌ Debug log failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Debug log error: $e');
    }
  }

  /// Get device information
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Send all buffered logs
  static Future<void> flushLogs() async {
    if (!_isEnabled || _logBuffer.isEmpty) return;
    
    try {
      final logs = _logBuffer.map((log) => {
        'level': log.level,
        'message': log.message,
        'data': log.data,
        'timestamp': log.timestamp.toIso8601String(),
      }).toList();
      
      final response = await http.post(
        Uri.parse('$_debugEndpoint/batch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'logs': logs}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        _logBuffer.clear();
        print('✅ Buffered logs sent successfully');
      }
    } catch (e) {
      print('❌ Failed to flush logs: $e');
    }
  }

  /// Enable/disable debug service
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Get current log buffer
  static List<DebugLog> getLogBuffer() {
    return List.from(_logBuffer);
  }

  /// Clear log buffer
  static void clearBuffer() {
    _logBuffer.clear();
  }
}

/// Debug log model
class DebugLog {
  final String level;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  DebugLog({
    required this.level,
    required this.message,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Debug logging functions
class Debug {
  static void info(String message, [Map<String, dynamic>? data]) {
    print('ℹ️ $message');
    DebugService.log('INFO', message, data);
  }

  static void warning(String message, [Map<String, dynamic>? data]) {
    print('⚠️ $message');
    DebugService.log('WARNING', message, data);
  }

  static void error(String message, [Map<String, dynamic>? data]) {
    print('❌ $message');
    DebugService.log('ERROR', message, data);
  }

  static void success(String message, [Map<String, dynamic>? data]) {
    print('✅ $message');
    DebugService.log('SUCCESS', message, data);
  }

  static void ai(String message, [Map<String, dynamic>? data]) {
    print('🤖 $message');
    DebugService.log('AI', message, data);
  }

  static void user(String message, [Map<String, dynamic>? data]) {
    print('👤 $message');
    DebugService.log('USER', message, data);
  }

  static void export(String message, [Map<String, dynamic>? data]) {
    print('📦 $message');
    DebugService.log('EXPORT', message, data);
  }
}
