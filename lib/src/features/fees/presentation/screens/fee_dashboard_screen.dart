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
      appBar: AppBar(title: const Text('Fee Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/fees/search'),
        icon: const Icon(Icons.search),
        label: const Text('Search'),
      ),
      body: ResponsivePage(
        maxWidth: 900,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppAsyncView(
            value: ledgers,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No outstanding dues',
                  message: 'Outstanding fee records will appear here.',
                );
              }
              return ListView.builder(
                itemCount: items.length,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
