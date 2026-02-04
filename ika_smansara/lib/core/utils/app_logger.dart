/// App Logger Utility
library;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logger instance
final AppLogger log = AppLogger();

/// Custom App Logger with Pretty Print and Context Support
class AppLogger {
  /// Singleton instance
  AppLogger._internal(this._logger);

  factory AppLogger() {
    return _instance;
  }

  static final AppLogger _instance = AppLogger._internal(
    Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        noBoxingByDefault: false,
      ),
      filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
      level: kReleaseMode ? Level.warning : Level.debug,
    ),
  );

  final Logger _logger;

  /// Debug level log - Detailed information for debugging
  void debug(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logger.log(Level.debug, message, error: error, stackTrace: stackTrace);
  }

  /// Info level log - General informational messages
  void info(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logger.log(Level.info, message, error: error, stackTrace: stackTrace);
  }

  /// Warning level log - Warning messages for potentially harmful situations
  void warning(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logger.log(Level.warning, message, error: error, stackTrace: stackTrace);
  }

  /// Error level log - Error events for important issues
  void error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logger.log(Level.error, message, error: error, stackTrace: stackTrace);
  }

  /// WTF level log - Terrible failures (What a Terrible Failure)
  void wtf(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logger.log(Level.trace, message, error: error, stackTrace: stackTrace);
  }

  /// Log with custom context/feature prefix
  void withContext(
    String context,
    LogLevel level,
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final prefixedMessage = '[$context] $message';

    switch (level) {
      case LogLevel.debug:
        debug(prefixedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        info(prefixedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        warning(prefixedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        this.error(prefixedMessage, error: error, stackTrace: stackTrace);
        break;
    }
  }
}

/// Log level enum
enum LogLevel { debug, info, warning, error }

/// Development filter - Show all logs in debug mode
class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

/// Production filter - Only show warnings and errors in production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.warning.index;
  }
}

/// Extension to make logging easier
extension AppLoggerExtension on AppLogger {
  /// Log API request
  void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    debug(
      'API Request',
      error:
          '''
Method: $method
URL: $url
Headers: ${headers?.toString() ?? '{}'}
Body: ${body?.toString() ?? '{}'}''',
    );
  }

  /// Log API response
  void apiResponse({
    required String url,
    required int statusCode,
    dynamic body,
    int? duration,
  }) {
    debug(
      'API Response',
      error:
          '''
URL: $url
Status: $statusCode
Duration: ${duration ?? 0}ms
Body: ${body?.toString() ?? 'No body'}''',
    );
  }

  /// Log API error
  void apiError({
    required String url,
    required int statusCode,
    String? message,
    dynamic error,
  }) {
    error(
      'API Error',
      error:
          '''
URL: $url
Status: $statusCode
Message: ${message ?? 'Unknown error'}''',
      stackTrace: error is StackTrace ? error : null,
    );
  }

  /// Log BLoC event
  void blocEvent({
    required String bloc,
    required String event,
    Map<String, dynamic>? data,
  }) {
    debug(
      'BLoC Event',
      error:
          '''
Bloc: $bloc
Event: $event
Data: ${data?.toString() ?? 'No data'}''',
    );
  }

  /// Log BLoC state change
  void blocStateChange({
    required String bloc,
    required String from,
    required String to,
  }) {
    debug(
      'BLoC State Change',
      error:
          '''
Bloc: $bloc
From: $from
To: $to''',
    );
  }

  /// Log navigation
  void navigation({
    required String from,
    required String to,
    Map<String, dynamic>? arguments,
  }) {
    info(
      'Navigation',
      error:
          '''
From: $from
To: $to
Arguments: ${arguments?.toString() ?? 'No arguments'}''',
    );
  }

  /// Log user action
  void userAction({
    required String action,
    String? screen,
    Map<String, dynamic>? properties,
  }) {
    info(
      'User Action',
      error:
          '''
Action: $action
Screen: ${screen ?? 'Unknown'}
Properties: ${properties?.toString() ?? 'No properties'}''',
    );
  }
}
