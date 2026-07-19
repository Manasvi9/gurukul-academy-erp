import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SupabaseSettingsRepository(ref.watch(supabaseClientProvider));
});

final settingsProvider = FutureProvider<AppSettings>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id;
  if (userId == null) throw Exception('User not authenticated');

  return ref.watch(settingsRepositoryProvider).getSettings(userId);
});
