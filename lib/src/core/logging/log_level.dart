enum LogLevel {
  debug(10),
  info(20),
  warning(30),
  error(40);

  const LogLevel(this.priority);

  final int priority;

  static LogLevel parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'debug' => LogLevel.debug,
      'info' => LogLevel.info,
      'warning' || 'warn' => LogLevel.warning,
      'error' => LogLevel.error,
      _ => throw FormatException('Unsupported LOG_LEVEL value: $value'),
    };
  }
}
