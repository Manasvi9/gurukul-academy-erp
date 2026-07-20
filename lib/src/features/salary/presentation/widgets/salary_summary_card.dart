import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

final class SalarySummaryCard extends StatelessWidget {
  const SalarySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surfaceContainerHighest;

    return Card(
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
