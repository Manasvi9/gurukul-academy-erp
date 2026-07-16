import '../../domain/entities/dashboard_card.dart';

final class DashboardCardModel extends DashboardCard {
  const DashboardCardModel({
    required super.key,
    required super.title,
    required super.value,
    required super.iconName,
    required super.routePath,
  });

  factory DashboardCardModel.fromJson(Map<String, Object?> json) {
    return DashboardCardModel(
      key: json['key'] as String,
      title: json['title'] as String,
      value: json['value'] as String,
      iconName: json['icon_name'] as String,
      routePath: json['route_path'] as String?,
    );
  }
}
