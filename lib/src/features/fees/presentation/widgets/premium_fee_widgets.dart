import 'package:flutter/material.dart';

// --- Reusable Fee UI Components ---

class FeeSummaryCard extends StatelessWidget {
  final double total;
  final double paid;
  final double pending;
  final double discount;
  final double scholarship;
  final double fine;
  final String nextDueDate;
  final String status;

  const FeeSummaryCard({
    super.key,
    required this.total,
    required this.paid,
    required this.pending,
    required this.discount,
    required this.scholarship,
    required this.fine,
    required this.nextDueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? paid / total : 0.0;
    Color statusColor = status == 'Fully Paid' ? Colors.green : (status == 'Overdue' ? Colors.red : Colors.orange);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Chip(label: Text(status), backgroundColor: statusColor.withOpacity(0.1), labelStyle: TextStyle(color: statusColor))),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: ₹${paid.toStringAsFixed(2)}'),
                Text('Pending: ₹${pending.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            _buildRow('Discount', '₹${discount.toStringAsFixed(2)}'),
            _buildRow('Scholarship', '₹${scholarship.toStringAsFixed(2)}'),
            _buildRow('Fine', '₹${fine.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value)],
    ),
  );
}

class NextDueCard extends StatelessWidget {
  final String installment;
  final String dueDate;
  final double amount;

  const NextDueCard({super.key, required this.installment, required this.dueDate, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.alarm, color: Colors.orange),
        title: Text('Next Due: $installment', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Due Date: $dueDate'),
        trailing: Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class InstallmentCard extends StatelessWidget {
  final Map<String, dynamic> installment;

  const InstallmentCard({super.key, required this.installment});

  @override
  Widget build(BuildContext context) {
    Color statusColor = installment['status'] == 'Paid' ? Colors.green : (installment['status'] == 'Overdue' ? Colors.red : Colors.orange);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(installment['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Due: ${installment['dueDate']}'),
        trailing: Chip(label: Text(installment['status']), backgroundColor: statusColor.withOpacity(0.1), labelStyle: TextStyle(color: statusColor)),
        children: [
          ListTile(title: const Text('Amount'), trailing: Text('₹${installment['amount']}')),
          ListTile(title: const Text('Paid Amount'), trailing: Text('₹${installment['paidAmount']}')),
          ListTile(title: const Text('Remaining Amount'), trailing: Text('₹${installment['amount'] - installment['paidAmount']}')),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text('Receipt: ${transaction['receiptNumber']}'),
      subtitle: Text('${transaction['date']} | ${transaction['mode']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
    );
  }
}

class FeeTimeline extends StatelessWidget {
  const FeeTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final events = ['Admission Fee Paid', 'Quarter 1 Paid', 'Transport Fee Paid'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: events.map((e) => Row(
          children: [
            const Icon(Icons.circle, size: 12, color: Colors.blue),
            const SizedBox(width: 16),
            Text(e),
          ],
        )).toList(),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  const AppEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(message, style: const TextStyle(color: Colors.grey))));
}

class FeeBreakdownTile extends StatelessWidget {
  final String category;
  final double amount;

  const FeeBreakdownTile({super.key, required this.category, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category),
      trailing: Text('₹${amount.toStringAsFixed(2)}'),
    );
  }
}

class FeeShimmer extends StatelessWidget {
  const FeeShimmer({super.key});
  @override
  Widget build(BuildContext context) => ListView.separated(padding: const EdgeInsets.all(16), itemCount: 4, separatorBuilder: (_, __) => const SizedBox(height: 16), itemBuilder: (_, __) => Container(height: 80, color: Colors.grey[200]));
}
