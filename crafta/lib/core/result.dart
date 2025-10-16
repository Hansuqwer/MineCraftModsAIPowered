/// Result pattern for error handling
/// Provides a type-safe way to handle success and error cases
class Result<T> {
  final T? data;
  final ErrorType? errorType;
  final String? errorMessage;
  final bool isSuccess;

  /// Create a successful result
  Result.success(this.data)
      : isSuccess = true,
        errorType = null,
        errorMessage = null;

  /// Create an error result
  Result.error(this.errorType, this.errorMessage)
      : isSuccess = false,
        data = null;

  /// Execute callback based on result type
  R when<R>({
    required R Function(T data) success,
    required R Function(ErrorType type, String message) error,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(errorType!, errorMessage!);
    }
  }

  /// Execute callback only on success
  void onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
  }

  /// Execute callback only on error
  void onError(void Function(ErrorType type, String message) callback) {
    if (!isSuccess) {
      callback(errorType!, errorMessage!);
    }
  }

  /// Map success value to another type
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return Result.success(transform(data as T));
    } else {
      return Result.error(errorType!, errorMessage!);
    }
  }
}

/// Types of errors that can occur in the app
enum ErrorType {
  /// Network connectivity error
  network,

  /// Request timeout error
  timeout,

  /// API rate limit exceeded
  rateLimited,

  /// Server error (5xx)
  serverError,

  /// Invalid input/validation error
  validation,

  /// API key not configured
  apiKeyMissing,

  /// Permission denied (microphone, etc)
  permissionDenied,

  /// Feature not available on platform
  notAvailable,

  /// Unknown/unexpected error
  unknown,
}

/// Extension to provide child-friendly error messages
extension ErrorTypeExtension on ErrorType {
  /// Get a child-friendly error message for display
  String get childFriendlyMessage {
    switch (this) {
      case ErrorType.network:
        return "Let's check if we're connected to the internet!";
      case ErrorType.timeout:
        return "That took too long! Let's try something quicker!";
      case ErrorType.rateLimited:
        return "Let's take a little break and try again soon!";
      case ErrorType.serverError:
        return "Our magic is taking a rest. Let's try again!";
      case ErrorType.validation:
        return "Let's try that in a different way!";
      case ErrorType.apiKeyMissing:
        return "We need to set up the magic key first!";
      case ErrorType.permissionDenied:
        return "We need permission to use that. Let's ask a grown-up!";
      case ErrorType.notAvailable:
        return "That feature isn't ready yet, but let's try something else!";
      case ErrorType.unknown:
        return "Something magical went wrong. Let's try again!";
    }
  }

  /// Get a technical error message for logging
  String get technicalMessage {
    switch (this) {
      case ErrorType.network:
        return "Network connectivity error";
      case ErrorType.timeout:
        return "Request timeout";
      case ErrorType.rateLimited:
        return "API rate limit exceeded";
      case ErrorType.serverError:
        return "Server error (5xx)";
      case ErrorType.validation:
        return "Validation error";
      case ErrorType.apiKeyMissing:
        return "API key not configured";
      case ErrorType.permissionDenied:
        return "Permission denied";
      case ErrorType.notAvailable:
        return "Feature not available";
      case ErrorType.unknown:
        return "Unknown error";
    }
  }
}
