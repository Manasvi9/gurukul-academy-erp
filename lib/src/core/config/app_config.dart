import '../logging/log_level.dart';

enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'development' || 'dev' => AppEnvironment.development,
      'staging' => AppEnvironment.staging,
      'production' || 'prod' => AppEnvironment.production,
      _ => throw FormatException('Unsupported APP_ENV value: $value'),
    };
  }
}

final class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.environment,
    required this.logLevel,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;
  final AppEnvironment environment;
  final LogLevel logLevel;

  bool get isProduction => environment == AppEnvironment.production;
}
