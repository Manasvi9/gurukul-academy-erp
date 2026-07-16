import 'dashboard_card.dart';
import 'dashboard_notification.dart';

final class DashboardSummary {
  const DashboardSummary({
    required this.role,
    required this.title,
    required this.cards,
    required this.notifications,
  });

  final String role;
  final String title;
  final List<DashboardCard> cards;
  final List<DashboardNotification> notifications;
}
