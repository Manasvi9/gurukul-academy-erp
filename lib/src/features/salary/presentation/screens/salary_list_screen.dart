import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/salary_providers.dart';
import '../widgets/salary_filter_bar.dart';
import '../widgets/salary_status_chip.dart';

final class SalaryListScreen extends ConsumerWidget {
  const SalaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider would ideally be combined with search and filter providers
    final employees = ref.watch(salaryPayrollListProvider('all-employees'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary List'),
      ),
      body: ResponsivePage(
        maxWidth: 1050,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(salaryPayrollListProvider);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by employee name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const SalaryFilterBar(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: AppAsyncView(
                    value: employees,
                    data: (items) => items.isEmpty
                        ? const AppEmptyView(
                            title: 'No salary records',
                            message: 'No records found for the selected criteria.',
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ListTile(
                                  title: Text('Employee ID: ${item.employeeId}'),
                                  subtitle: Text(
                                      'Net: ₹${item.netSalary.toStringAsFixed(0)}',),
                                  trailing: SalaryStatusChip(status: item.status),
                                  onTap: () {
                                    // Navigate to SalaryDetailsScreen
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
