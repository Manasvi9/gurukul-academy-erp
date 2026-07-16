import 'package:flutter/material.dart';

import '../../domain/entities/student_fee_ledger.dart';

final class FeeLedgerCard extends StatelessWidget {
  const FeeLedgerCard({
    required this.ledger,
    required this.onTap,
    super.key,
  });

  final StudentFeeLedger ledger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(ledger.studentName),
        subtitle: Text('${ledger.className} ${ledger.sectionName} • ${ledger.srNumber}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Due'),
            Text(ledger.outstandingDue.toStringAsFixed(0)),
          ],
        ),
      ),
    );
  }
}
