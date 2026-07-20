import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/salary_entities.dart';
import 'salary_status_chip.dart';

final class SalaryRecordTile extends StatelessWidget {
  const SalaryRecordTile({
    required this.payroll,
    required this.onTap,
    super.key,
  });

  final SalaryPayroll payroll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.receipt_long_outlined),
        ),
        title: Text(
          '${payroll.month}/${payroll.year}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('Net: ₹${payroll.netSalary.toStringAsFixed(0)}'),
        trailing: SalaryStatusChip(status: payroll.status),
      ),
    );
  }
}
