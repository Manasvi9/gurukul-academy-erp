import 'dart:developer' as developer;

import 'log_level.dart';

final class AppLogger {
  const AppLogger({required this.minimumLevel});

  final LogLevel minimumLevel;

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.priority < minimumLevel.priority) {
      return;
    }

    developer.log(
      message,
      name: 'GurukulAcademy',
      level: level.priority,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
