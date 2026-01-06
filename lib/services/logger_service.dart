import 'package:flutter/foundation.dart';
import 'crash_reporting_service.dart';

/// A service to handle application logging centrally.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  /// Logs an info message.
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  /// Logs a warning message.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  /// Logs an error message.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);

    // In production, automatically report errors to CrashReportingService
    if (!kDebugMode && (error != null || stackTrace != null)) {
       CrashReportingService().recordError(error, stackTrace, reason: message);
    }
  }

  void _log(String level, String message, dynamic error, StackTrace? stackTrace) {
    // SECURITY: Ensure logs are only printed in debug mode to prevent data leakage in release builds
    if (kDebugMode) {
      debugPrint('[$level] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
