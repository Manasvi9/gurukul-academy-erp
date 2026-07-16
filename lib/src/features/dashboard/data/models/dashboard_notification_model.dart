import '../../domain/entities/dashboard_notification.dart';

final class DashboardNotificationModel extends DashboardNotification {
  const DashboardNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
  });

  factory DashboardNotificationModel.fromJson(Map<String, Object?> json) {
    return DashboardNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
