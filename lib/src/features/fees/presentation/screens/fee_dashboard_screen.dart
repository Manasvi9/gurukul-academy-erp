import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/fee_providers.dart';
import '../widgets/fee_ledger_card.dart';

final class FeeDashboardScreen extends ConsumerWidget {
  const FeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgers = ref.watch(feeDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fee Management'),
            Text(
              'Outstanding fee dashboard',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/fees/search'),
        icon: const Icon(Icons.search),
        label: const Text('Search Student'),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppAsyncView(
            value: ledgers,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No Outstanding Dues',
                  message: 'All students have cleared their pending fees.',
                );
              }

              return Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            child: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${items.length} Pending Fee Records',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap any student to view fee details and collect payment.',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final ledger = items[index];

                        return FeeLedgerCard(
                          ledger: ledger,
                          onTap: () => context.go(
                            '/fees/students/${ledger.studentId}'
                            '?academicYearId=${ledger.academicYearId}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}