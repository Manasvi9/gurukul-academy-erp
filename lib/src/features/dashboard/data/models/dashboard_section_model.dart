import '../../domain/entities/dashboard_activity.dart';
import '../../domain/entities/dashboard_section.dart';

final class DashboardSectionModel extends DashboardSection {
  const DashboardSectionModel({
    required super.title,
    required super.emptyMessage,
    required super.items,
  });

  factory DashboardSectionModel.fromJson(Map<String, Object?> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .cast<Map<String, Object?>>()
        .map(
          (item) => DashboardActivity(
            id: item['id'] as String,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
          ),
        )
        .toList();

    return DashboardSectionModel(
      title: json['title'] as String,
      emptyMessage: json['empty_message'] as String,
      items: items,
    );
  }
}
