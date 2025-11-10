/// Simple logger utility for ChoreQuest
library;

import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Logger levels
enum LogLevel { debug, info, warning, error }

/// Simple logger class
class Logger {
  final String _tag;

  Logger(this._tag);

  /// Log debug message
  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// Log info message
  void info(String message) {
    _log(LogLevel.info, message);
  }

  /// Log warning message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message);
    if (error != null) {
      _log(LogLevel.warning, 'Error: $error');
    }
    if (stackTrace != null) {
      _log(LogLevel.warning, 'StackTrace: $stackTrace');
    }
  }

  /// Log error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message);
    if (error != null) {
      _log(LogLevel.error, 'Error: $error');
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'StackTrace: $stackTrace');
    }
  }

  /// Internal log method
  void _log(LogLevel level, String message) {
    // Only log in debug mode or if enableDebugLog is true
    if (!kDebugMode && !EnvironmentConfig.enableDebugLog) {
      return;
    }

    final emoji = _getEmoji(level);
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$emoji [$timestamp] [$_tag] $message';

    // Use debugPrint instead of print (recommended by Flutter)
    debugPrint(logMessage);
  }

  /// Get emoji for log level
  String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

/// Global logger factory
class Log {
  static final Map<String, Logger> _loggers = {};

  /// Get or create logger for a tag
  static Logger get(String tag) {
    return _loggers.putIfAbsent(tag, () => Logger(tag));
  }
}
