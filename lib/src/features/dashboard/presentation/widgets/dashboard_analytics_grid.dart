import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/dashboard_card.dart';
import 'dashboard_metric_card.dart';

final class DashboardAnalyticsGrid extends StatelessWidget {
  const DashboardAnalyticsGrid({
    required this.cards,
    required this.onCardTap,
    super.key,
  });

  final List<DashboardCard> cards;
  final void Function(DashboardCard card) onCardTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: columns == 1 ? 4.2 : 2.6,
          children: cards
              .map(
                (card) => DashboardMetricCard(
                  card: card,
                  onTap: card.routePath == null ? null : () => onCardTap(card),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
