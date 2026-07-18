final class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.audience,
    required this.publishedOn,
    this.expiresOn,
  });
  final String id;
  final String title;
  final String description;
  final String type;
  final String audience;
  final DateTime publishedOn;
  final DateTime? expiresOn;
}
