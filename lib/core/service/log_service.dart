import 'dart:developer';
import 'package:flutter/foundation.dart';

enum LogLevel {
  info,
  warning,
  error,
  debug,
  critical,
}

class AppLog {
  AppLog._private();

  static final AppLog instance = AppLog._private();

  // Helper function to get current timestamp
  String _getTimestamp() {
    return DateTime.now().toIso8601String();
  }

  // Core logging function
  void logMessage(String message, LogLevel level, {dynamic error, StackTrace? stackTrace}) {
    final logEntry = '[${_getTimestamp()}] [${level.name}] $message'; // Updated to use level.name

    // Log to console with different severity levels
    if (level == LogLevel.error || level == LogLevel.critical) {
      log(logEntry, error: error, stackTrace: stackTrace, level: 1000);
    } else {
      log(logEntry, level: _getLogLevel(level));
    }

    // Optionally send critical logs to external services
    if (level == LogLevel.critical && !kReleaseMode) {
      _sendToExternalService(logEntry, error, stackTrace);
    }
  }

  // Info log
  void info(String message) {
    logMessage(message, LogLevel.info);
  }

  // Warning log
  void warning(String message) {
    logMessage(message, LogLevel.warning);
  }

  // Error log
  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    logMessage(message, LogLevel.error, error: error, stackTrace: stackTrace);
  }

  // Debug log
  void debug(String message) {
    if (!kReleaseMode) {
      logMessage(message, LogLevel.debug);
    }
  }

  // Critical log (for crashes or major failures)
  void critical(String message, {dynamic error, StackTrace? stackTrace}) {
    logMessage(message, LogLevel.critical, error: error, stackTrace: stackTrace);
  }

  // Map log level to system log level
  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1100;
      default:
        return 500;
    }
  }

  // Simulate sending logs to an external service (e.g., Sentry, Firebase Crashlytics)
  void _sendToExternalService(String logEntry, dynamic error, StackTrace? stackTrace) {
    // Here, integrate services like Sentry, Firebase Crashlytics, or any other crash reporting service.
    log('Critical log sent to external service: $logEntry', level: 1100);
  }
}
