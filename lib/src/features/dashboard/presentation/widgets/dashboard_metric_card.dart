import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_card.dart';

final class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.card,
    required this.onTap,
    super.key,
  });

  final DashboardCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(_iconForName(card.iconName), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForName(String name) {
    return switch (name) {
      'groups' => Icons.groups_outlined,
      'school' => Icons.school_outlined,
      'payments' => Icons.payments_outlined,
      'fact_check' => Icons.fact_check_outlined,
      'assignment' => Icons.assignment_outlined,
      'event' => Icons.event_outlined,
      'pending_actions' => Icons.pending_actions_outlined,
      'notifications' => Icons.notifications_outlined,
      'calendar_view_day' => Icons.calendar_view_day_outlined,
      'grading' => Icons.grading_outlined,
      'person' => Icons.person_outline,
      _ => Icons.dashboard_outlined,
    };
  }
}
