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
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconForName(card.iconName),
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                card.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForName(String name) {
    return switch (name.toLowerCase().trim()) {
      'students' => Icons.school_outlined,
      'teachers' => Icons.person_outline,
      'attendance' => Icons.fact_check_outlined,
      'fees' => Icons.payments_outlined,
      'homework' => Icons.assignment_outlined,
      'exams' => Icons.quiz_outlined,
      'transport' => Icons.directions_bus_outlined,
      'salary' => Icons.currency_rupee_outlined,
      'gallery' => Icons.photo_library_outlined,
      'notifications' => Icons.notifications_outlined,
      'events' => Icons.event_outlined,
      'leave' => Icons.event_busy_outlined,
      'reports' => Icons.bar_chart_outlined,
      'settings' => Icons.settings_outlined,
      _ => Icons.dashboard_outlined,
    };
  }
}