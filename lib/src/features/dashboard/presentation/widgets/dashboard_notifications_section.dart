import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../domain/entities/dashboard_notification.dart';

final class DashboardNotificationsSection extends StatelessWidget {
  const DashboardNotificationsSection({
    required this.title,
    required this.notifications,
    super.key,
  });

  final String title;
  final List<DashboardNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (notifications.isEmpty)
          const AppEmptyView(
            title: 'No notifications',
            message: 'Recent notices will appear here.',
          )
        else
          ...notifications.map(
            (notification) => Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: Text(DateFormatter.displayDate(notification.createdAt)),
              ),
            ),
          ),
      ],
    );
  }
}
