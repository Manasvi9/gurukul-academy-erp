class DashboardCard {
  const DashboardCard({
    required this.key,
    required this.title,
    required this.value,
    required this.iconName,
    required this.routePath,
  });

  final String key;
  final String title;
  final String value;
  final String iconName;
  final String? routePath;
}
