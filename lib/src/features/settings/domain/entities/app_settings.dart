enum AppTheme { light, dark, system }

final class AppSettings {
  const AppSettings({
    required this.theme,
    required this.notificationsEnabled,
  });

  final AppTheme theme;
  final bool notificationsEnabled;
}
