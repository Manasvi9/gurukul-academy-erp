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
        final columns = switch (constraints.maxWidth) {
          >= 1400 => 4,
          >= 1000 => 3,
          >= 650 => 2,
          _ => 1,
        };

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
          childAspectRatio: columns == 1 ? 1.8 : 1.25,
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
