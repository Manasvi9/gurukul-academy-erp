import '../../domain/entities/dashboard_summary.dart';
import 'dashboard_card_model.dart';
import 'dashboard_notification_model.dart';
import 'dashboard_section_model.dart';

final class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.role,
    required super.title,
    required super.cards,
    required super.notifications,
    super.sections,
  });

  factory DashboardSummaryModel.fromJson(Map<String, Object?> json) {
    final cards = (json['cards'] as List<dynamic>? ?? [])
        .cast<Map<String, Object?>>()
        .map(DashboardCardModel.fromJson)
        .toList();
    final notifications = (json['notifications'] as List<dynamic>? ?? [])
        .cast<Map<String, Object?>>()
        .map(DashboardNotificationModel.fromJson)
        .toList();
    final sections = (json['sections'] as List<dynamic>? ?? [])
        .cast<Map<String, Object?>>()
        .map(DashboardSectionModel.fromJson)
        .toList();

    return DashboardSummaryModel(
      role: json['role'] as String,
      title: json['title'] as String,
      cards: cards,
      notifications: notifications,
      sections: sections,
    );
  }
}
