import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../students/presentation/widgets/premium_student_widgets.dart' as student_widgets;
import '../widgets/premium_fee_widgets.dart' as fee_widgets;

class FeeStudentLedgerScreen extends ConsumerWidget {
  final String studentId;
  final String academicYearId;

  const FeeStudentLedgerScreen({required this.studentId, required this.academicYearId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userRole = authState.user?.role.value ?? '';
    final permissions = student_widgets.rolePermissions[userRole] ?? {};

    // Mock data for display - replace with provider

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fees Details'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(child: Text('Download Receipt')),
                const PopupMenuItem(child: Text('Download Statement')),
                const PopupMenuItem(child: Text('Print Statement')),
                const PopupMenuItem(child: Text('Share Statement')),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Payment History'),
            Tab(text: 'Fee Breakdown'),
          ],),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            ListView(
              children: [
                const fee_widgets.FeeSummaryCard(
                  total: 50000, paid: 37500, pending: 12500, discount: 500, scholarship: 2000, fine: 0, nextDueDate: '15-Aug-2026', status: 'Partially Paid',
                ),
                const fee_widgets.NextDueCard(installment: 'Q2 Installment', dueDate: '15-Aug-2026', amount: 7500),
                ...[
                  {'name': 'Q1 Installment', 'dueDate': '01-Apr-2026', 'status': 'Paid', 'amount': 15000, 'paidAmount': 15000},
                  {'name': 'Q2 Installment', 'dueDate': '01-Jul-2026', 'status': 'Pending', 'amount': 15000, 'paidAmount': 7500},
                ].map((i) => fee_widgets.InstallmentCard(installment: i)),
                const fee_widgets.FeeTimeline(),
                if (permissions.contains(student_widgets.AppPermission.viewFees))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FilledButton(onPressed: () {}, child: const Text('Pay Now')),
                  ),
              ],
            ),
            // History Tab
            ListView(children: [fee_widgets.TransactionTile(transaction: const {'receiptNumber': 'REC001', 'date': '01-Apr-2026', 'mode': 'UPI', 'amount': 15000})]),
            // Breakdown Tab
            ListView(children: [
                  fee_widgets.FeeBreakdownTile(category: 'Tuition Fee', amount: 30000), 
                  fee_widgets.FeeBreakdownTile(category: 'Transport Fee', amount: 10000),
                ],),
            ],
            ),
            ),
            );
            }
            }
