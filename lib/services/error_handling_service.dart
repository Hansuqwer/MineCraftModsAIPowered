import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

/// Comprehensive Error Handling Service
/// Provides centralized error management with user-friendly messages
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final List<ErrorLog> _errorLogs = [];
  final StreamController<AppError> _errorController = StreamController<AppError>.broadcast();

  /// Stream of errors for UI to listen to
  Stream<AppError> get errorStream => _errorController.stream;

  /// Log an error with context
  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? metadata,
  }) {
    final appError = AppError(
      message: message,
      originalError: error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );

    _errorLogs.add(ErrorLog.fromAppError(appError));

    // Emit error to stream for UI handling
    _errorController.add(appError);

    // Log to console in debug mode
    if (kDebugMode) {
      print('🚨 ERROR [$severity]: $message');
      if (error != null) print('   Original: $error');
      if (context != null) print('   Context: $context');
    }
  }

  /// Handle network errors
  void handleNetworkError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;

    if (error is SocketException) {
      message = 'No internet connection. Please check your network and try again.';
      severity = ErrorSeverity.high;
    } else if (error is TimeoutException) {
      message = 'Request timed out. Please try again.';
      severity = ErrorSeverity.medium;
    } else if (error is HttpException) {
      message = 'Network error occurred. Please try again.';
      severity = ErrorSeverity.medium;
    } else {
      message = 'Network connection failed. Please try again.';
      severity = ErrorSeverity.medium;
    }

    logError(
      message,
      error: error,
      context: context ?? 'Network',
      severity: severity,
    );
  }

  /// Handle AI service errors
  void handleAIError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;

    if (error.toString().contains('rate limit') || error.toString().contains('429')) {
      message = 'AI service is busy. Please wait a moment and try again.';
      severity = ErrorSeverity.medium;
    } else if (error.toString().contains('unauthorized') || error.toString().contains('401')) {
      message = 'AI service authentication failed. Please check your API keys.';
      severity = ErrorSeverity.high;
    } else if (error.toString().contains('quota') || error.toString().contains('limit')) {
      message = 'AI service quota exceeded. Please try again later.';
      severity = ErrorSeverity.medium;
    } else {
      message = 'AI service temporarily unavailable. Using offline mode.';
      severity = ErrorSeverity.low;
    }

    logError(
      message,
      error: error,
      context: context ?? 'AI Service',
      severity: severity,
    );
  }

  /// Handle speech recognition errors
  void handleSpeechError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;

    if (error.toString().contains('permission')) {
      message = 'Microphone permission required. Please enable it in settings.';
      severity = ErrorSeverity.high;
    } else if (error.toString().contains('not available')) {
      message = 'Speech recognition not available on this device.';
      severity = ErrorSeverity.medium;
    } else if (error.toString().contains('timeout')) {
      message = 'Speech recognition timed out. Please try again.';
      severity = ErrorSeverity.low;
    } else {
      message = 'Speech recognition failed. Please try again.';
      severity = ErrorSeverity.low;
    }

    logError(
      message,
      error: error,
      context: context ?? 'Speech Recognition',
      severity: severity,
    );
  }

  /// Handle 3D rendering errors
  void handle3DRenderingError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;

    if (error.toString().contains('WebView')) {
      message = '3D preview not available. Using fallback display.';
      severity = ErrorSeverity.low;
    } else if (error.toString().contains('Babylon')) {
      message = '3D engine failed to load. Using simplified preview.';
      severity = ErrorSeverity.low;
    } else {
      message = '3D preview error. Using fallback display.';
      severity = ErrorSeverity.low;
    }

    logError(
      message,
      error: error,
      context: context ?? '3D Rendering',
      severity: severity,
    );
  }

  /// Handle Minecraft export errors
  void handleExportError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;

    if (error.toString().contains('permission')) {
      message = 'File access permission required. Please enable it in settings.';
      severity = ErrorSeverity.high;
    } else if (error.toString().contains('storage')) {
      message = 'Insufficient storage space. Please free up some space.';
      severity = ErrorSeverity.medium;
    } else if (error.toString().contains('format')) {
      message = 'Export format error. Please try again.';
      severity = ErrorSeverity.medium;
    } else {
      message = 'Export failed. Please try again.';
      severity = ErrorSeverity.medium;
    }

    logError(
      message,
      error: error,
      context: context ?? 'Minecraft Export',
      severity: severity,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return '${error.message} No worries, you can continue using the app.';
      case ErrorSeverity.medium:
        return '${error.message} Please try again in a moment.';
      case ErrorSeverity.high:
        return '${error.message} Please check your settings and try again.';
      case ErrorSeverity.critical:
        return '${error.message} Please restart the app and try again.';
    }
  }

  /// Get error icon based on severity
  IconData getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.high:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.error;
    }
  }

  /// Get error color based on severity
  Color getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade800;
    }
  }

  /// Get recent errors
  List<ErrorLog> getRecentErrors({int limit = 10}) {
    final sortedLogs = List<ErrorLog>.from(_errorLogs);
    sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedLogs.take(limit).toList();
  }

  /// Clear error logs
  void clearErrorLogs() {
    _errorLogs.clear();
  }

  /// Dispose resources
  void dispose() {
    _errorController.close();
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// App Error Model
class AppError {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final String? context;
  final ErrorSeverity severity;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const AppError({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.context,
    required this.severity,
    required this.metadata,
    required this.timestamp,
  });
}

/// Error Log Model
class ErrorLog {
  final String id;
  final String message;
  final String? context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ErrorLog({
    required this.id,
    required this.message,
    this.context,
    required this.severity,
    required this.timestamp,
    required this.metadata,
  });

  factory ErrorLog.fromAppError(AppError error) {
    return ErrorLog(
      id: '${error.timestamp.millisecondsSinceEpoch}_${error.message.hashCode}',
      message: error.message,
      context: error.context,
      severity: error.severity,
      timestamp: error.timestamp,
      metadata: error.metadata,
    );
  }
}

/// Error Display Widget
class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final errorService = ErrorHandlingService();
    final userMessage = errorService.getUserFriendlyMessage(error);
    final icon = errorService.getErrorIcon(error.severity);
    final color = errorService.getErrorColor(error.severity);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userMessage,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  color: color,
                ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Try Again',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Global Error Handler
class GlobalErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandlingService().logError(
        'Flutter Framework Error',
        error: details.exception,
        stackTrace: details.stack,
        context: 'Flutter Framework',
        severity: ErrorSeverity.critical,
      );
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorHandlingService().logError(
        'Platform Error',
        error: error,
        stackTrace: stack,
        context: 'Platform',
        severity: ErrorSeverity.critical,
      );
      return true;
    };
  }
}
