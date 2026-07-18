import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> getSettings(String userId);
  Future<void> updateSettings({
    required String userId,
    AppTheme? theme,
    bool? notificationsEnabled,
  });
}
