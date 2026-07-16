import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/app_exception.dart';
import '../logging/log_level.dart';
import 'app_config.dart';

final class EnvironmentLoader {
  const EnvironmentLoader._();

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = _required('SUPABASE_URL');
    final supabasePublishableKey = _required('SUPABASE_PUBLISHABLE_KEY');
    final environment = AppEnvironment.parse(
      dotenv.get('APP_ENV', fallback: 'development'),
    );
    final logLevel = LogLevel.parse(
      dotenv.get('LOG_LEVEL', fallback: 'info'),
    );

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabasePublishableKey: supabasePublishableKey,
      environment: environment,
      logLevel: logLevel,
    );
  }

  static String _required(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty) {
      throw ConfigurationException('Missing required environment key: $key');
    }
    return value;
  }
}
