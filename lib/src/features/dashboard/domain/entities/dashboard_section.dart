import 'dashboard_activity.dart';

class DashboardSection {
  const DashboardSection({
    required this.title,
    required this.emptyMessage,
    required this.items,
  });

  final String title;
  final String emptyMessage;
  final List<DashboardActivity> items;
}
