import 'dashboard_card.dart';
import 'dashboard_notification.dart';
import 'dashboard_section.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.role,
    required this.title,
    required this.cards,
    required this.notifications,
    this.sections = const [],
  });

  final String role;
  final String title;
  final List<DashboardCard> cards;
  final List<DashboardNotification> notifications;
  final List<DashboardSection> sections;
}
