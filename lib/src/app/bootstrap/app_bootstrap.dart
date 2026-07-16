import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/config/environment_loader.dart';
import '../../core/logging/app_logger.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('AppConfig was not provided during bootstrap.');
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger(
    minimumLevel: ref.watch(appConfigProvider).logLevel,
  );
});

final class AppBootstrap {
  const AppBootstrap._();

  static Future<ProviderContainer> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final config = await EnvironmentLoader.load();

    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );

    return ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
    );
  }
}
