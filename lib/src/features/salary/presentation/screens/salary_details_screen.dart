import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/salary_providers.dart';
import '../widgets/salary_record_tile.dart';
import '../widgets/salary_summary_card.dart';

final class SalaryDetailsScreen extends ConsumerWidget {
  const SalaryDetailsScreen({
    required this.employeeId,
    super.key,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // These providers need to be family providers to accept employeeId
    final payrolls = ref.watch(salaryPayrollListProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Details'),
      ),
      body: ResponsivePage(
        maxWidth: 1050,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Info Section
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Employee ID: $employeeId'),
                  subtitle: const Text('Teacher'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Summary
              Row(
                children: [
                  Expanded(
                    child: SalarySummaryCard(
                        title: 'Total Earned', value: '₹45,000', icon: Icons.payments,),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SalarySummaryCard(
                        title: 'Advances', value: '₹5,000', icon: Icons.money_off,),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Payroll History
              Text('Payroll History', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              AppAsyncView(
                value: payrolls,
                data: (items) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) => SalaryRecordTile(
                    payroll: items[index],
                    onTap: () {},
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate Slip'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.payments),
                      label: const Text('Record Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
