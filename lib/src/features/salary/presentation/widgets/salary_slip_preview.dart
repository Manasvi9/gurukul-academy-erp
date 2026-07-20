import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/salary_entities.dart';

final class SalarySlipPreview extends StatelessWidget {
  const SalarySlipPreview({
    required this.payroll,
    super.key,
  });

  final SalaryPayroll payroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text('Salary Slip', style: theme.textTheme.headlineSmall),
            const Divider(),
            _buildRow(context, 'Basic Salary', '₹${payroll.basicSalary}'),
            _buildRow(context, 'Attendance Deduction', '-₹${payroll.attendanceDeduction}'),
            _buildRow(context, 'Advance Deduction', '-₹${payroll.advanceDeduction}'),
            const Divider(),
            _buildRow(context, 'Net Salary', '₹${payroll.netSalary}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
