import 'package:flutter/material.dart';

import '../../domain/entities/salary_payment_enums.dart';

final class SalaryStatusChip extends StatelessWidget {
  const SalaryStatusChip({
    required this.status,
    super.key,
  });

  final SalaryPaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      SalaryPaymentStatus.pending => theme.colorScheme.error,
      SalaryPaymentStatus.paid => theme.colorScheme.primary,
      SalaryPaymentStatus.partial => theme.colorScheme.tertiary,
    };

    return Chip(
      label: Text(
        status.label,
        style: TextStyle(color: color),
      ),
      side: BorderSide(color: color),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
