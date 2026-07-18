import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_analytics_grid.dart';
import '../widgets/dashboard_notifications_section.dart';
import '../widgets/dashboard_sections.dart';

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
                  DashboardAnalyticsGrid(
                    cards: dashboard.cards,
                    onCardTap: (card) => context.go(card.routePath!),
                  ),
                  if (dashboard.sections.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    DashboardSections(sections: dashboard.sections),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  DashboardNotificationsSection(
                    title: dashboard.role == 'teacher'
                        ? 'Recent Notices'
                        : 'Recent Notifications',
                    notifications: dashboard.notifications,
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
