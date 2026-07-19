import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/fee_payment_form_data.dart';
import '../../domain/entities/student_fee_ledger.dart';
import '../providers/fee_providers.dart';

final class FeeStudentLedgerScreen extends ConsumerWidget {
  const FeeStudentLedgerScreen({
    required this.studentId,
    required this.academicYearId,
    super.key,
  });

  final String studentId;
  final String academicYearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = FeeLedgerRequest(
      studentId: studentId,
      academicYearId: academicYearId,
    );
    final ledger = ref.watch(studentFeeLedgerProvider(request));
    final payments = ref.watch(feePaymentHistoryProvider(request));

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Ledger')),
      body: ResponsivePage(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppAsyncView(
              value: ledger,
              data: (value) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.studentName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Class Fee: ${value.classFee.toStringAsFixed(0)}'),
                      Text(
                        'Transport: ${value.transportFee.toStringAsFixed(0)}',
                      ),
                      Text(
                        'Discount: ${value.scholarshipDiscount.toStringAsFixed(0)}',
                      ),
                      Text('Paid: ${value.paidAmount.toStringAsFixed(0)}'),
                      Text('Due: ${value.outstandingDue.toStringAsFixed(0)}'),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                _recordPayment(context, ref, value),
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Record Payment'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: () => _markComplete(context, ref, value),
                            child: const Text('Mark Complete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppAsyncView(
              value: payments,
              data: (items) => Column(
                children: items.map((payment) {
                  return ListTile(
                    title: Text(payment.amount.toStringAsFixed(0)),
                    subtitle: Text(payment.paymentMode),
                    trailing: Text(payment.status.value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    StudentFeeLedger ledger,
  ) async {
    final amountController = TextEditingController(
      text: ledger.outstandingDue.toStringAsFixed(0),
    );
    final modeController = TextEditingController(text: 'Cash');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: modeController,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(feePaymentControllerProvider.notifier).record(
          FeePaymentFormData(
            studentId: ledger.studentId,
            academicYearId: ledger.academicYearId,
            amount: num.parse(amountController.text),
            paymentDate: DateTime.now(),
            paymentMode: modeController.text,
            referenceNumber: '',
            note: '',
          ),
        );
    ref.invalidate(studentFeeLedgerProvider);
    ref.invalidate(feePaymentHistoryProvider);
  }

  Future<void> _markComplete(
    BuildContext context,
    WidgetRef ref,
    StudentFeeLedger ledger,
  ) async {
    await ref.read(feePaymentControllerProvider.notifier).markComplete(
          studentId: ledger.studentId,
          academicYearId: ledger.academicYearId,
          note: 'Marked complete from fee ledger.',
        );
    ref.invalidate(studentFeeLedgerProvider);
  }
}
