import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/salary_payment_enums.dart';
import '../providers/salary_providers.dart';

final class SalaryFilterBar extends ConsumerWidget {
  const SalaryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Month'),
            initialValue: ref.watch(salaryFilterMonthProvider),
            items: List.generate(12, (index) => index + 1)
                .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                .toList(),
            onChanged: (v) => ref.read(salaryFilterMonthProvider.notifier).set(v),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<SalaryPaymentStatus>(
            decoration: const InputDecoration(labelText: 'Status'),
            initialValue: ref.watch(salaryFilterStatusProvider),
            items: SalaryPaymentStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) => ref.read(salaryFilterStatusProvider.notifier).set(v),
          ),
        ),
      ],
    );
  }
}
