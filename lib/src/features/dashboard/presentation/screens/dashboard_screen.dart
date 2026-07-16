import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_metric_card.dart';

final class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gurukul Academy'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 1100,
        child: AppAsyncView(
          value: summary,
          data: (dashboard) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardSummaryProvider);
                await ref.read(dashboardSummaryProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    dashboard.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
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
                        children: dashboard.cards.map((card) {
                          return DashboardMetricCard(
                            card: card,
                            onTap: card.routePath == null
                                ? null
                                : () => context.go(card.routePath!),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Recent Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (dashboard.notifications.isEmpty)
                    const AppEmptyView(
                      title: 'No notifications',
                      message: 'Recent notifications will appear here.',
                    )
                  else
                    ...dashboard.notifications.map(
                      (notification) => ListTile(
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
