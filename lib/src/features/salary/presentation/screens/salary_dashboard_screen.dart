import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/salary_providers.dart';
import '../widgets/salary_filter_bar.dart';
import '../widgets/salary_record_tile.dart';
import '../widgets/salary_summary_card.dart';

final class SalaryDashboardScreen extends ConsumerWidget {
  const SalaryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(salaryDashboardStatsProvider);
    // Fetch all payrolls
    final payrolls = ref.watch(salaryPayrollListProvider('all'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Dashboard'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigation logic for generating payroll
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Generate Payroll'),
      ),
      body: ResponsivePage(
        maxWidth: 1050,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAsyncView(
                value: stats,
                data: (data) => Row(
                  children: [
                    Expanded(
                      child: SalarySummaryCard(
                        title: 'Total Payroll',
                        value: '₹${data['total_payroll']}',
                        icon: Icons.account_balance,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SalarySummaryCard(
                        title: 'Paid',
                        value: '₹${data['paid_salaries']}',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SalarySummaryCard(
                        title: 'Pending',
                        value: '₹${data['pending_salaries']}',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SalaryFilterBar(),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Recent Payroll',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: AppAsyncView(
                  value: payrolls,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No payroll records',
                          message: 'Generate payroll to see records here.',
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) => SalaryRecordTile(
                            payroll: items[index],
                            onTap: () {
                              context.pushNamed(
                                'salary-details',
                                pathParameters: {'employeeId': items[index].employeeId},
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
