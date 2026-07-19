import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class SupabaseSettingsRepository implements SettingsRepository {
  SupabaseSettingsRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<AppSettings> getSettings(String userId) async {
    final response = await _client
        .from('user_settings')
        .select('theme, notifications_enabled')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return const AppSettings(
          theme: AppTheme.system, notificationsEnabled: true,);
    }

    return AppSettings(
      theme: AppTheme.values.byName(response['theme'] as String),
      notificationsEnabled: response['notifications_enabled'] as bool,
    );
  }

  @override
  Future<void> updateSettings({
    required String userId,
    AppTheme? theme,
    bool? notificationsEnabled,
  }) async {
    final updates = <String, dynamic>{};
    if (theme != null) updates['theme'] = theme.name;
    if (notificationsEnabled != null) {
      updates['notifications_enabled'] = notificationsEnabled;
    }

    await _client.from('user_settings').upsert({...updates, 'user_id': userId});
  }
}
