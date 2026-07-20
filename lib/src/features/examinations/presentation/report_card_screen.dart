import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../students/domain/entities/student_summary.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/student_result.dart';
import 'report_card_providers.dart';

class ReportCardScreen extends ConsumerWidget {
  const ReportCardScreen({
    required this.exam,
    required this.student,
    required this.result,
    super.key,
  });
  final Exam exam;
  final StudentSummary student;
  final StudentResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marksAsync = ref.watch(
      studentExamMarksProvider(
        (examId: exam.id, studentId: student.id),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Report Card"),
            Text(
              exam.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ResponsivePage(
        maxWidth: 950,
        child: AppAsyncView<List<StudentReportMark>>(
          value: marksAsync,
          data: (marks) {
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                _buildHeader(context),
                _buildStudentDetails(context),
                _buildMarksTable(context, marks),
                _buildResultBanner(context),
                _buildSummary(context),
                _buildFooter(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 34,
              child: Icon(
                Icons.school,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Gurukul Academy",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "Academic Report Card",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Chip(
              avatar: const Icon(Icons.quiz_outlined),
              label: Text(exam.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                student.name.characters.first,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Roll No. ${student.rollNumber ?? '-'}",
                  ),
                  Text(
                    "${student.className} • ${student.sectionName}",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksTable(
    BuildContext context,
    List<StudentReportMark> marks,
  ) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subject Performance",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: 56,
                columnSpacing: 32,
                columns: const [
                  DataColumn(label: Text("Subject")),
                  DataColumn(label: Text("Max")),
                  DataColumn(label: Text("Obtained")),
                  DataColumn(label: Text("Status")),
                ],
                rows: marks.map((entry) {
                  final subject = entry.subject;
                  final mark = entry.mark;

                  final absent = mark.isFinal && mark.marks == null;
                  final passed = !absent && (mark.marks ?? 0) >= subject.passingMarks;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(subject.subjectId),
                      ),
                      DataCell(
                        Text(subject.maximumMarks.toStringAsFixed(0)),
                      ),
                      DataCell(
                        Text(absent ? "AB" : (mark.marks ?? 0).toStringAsFixed(0)),
                      ),
                      DataCell(
                        Chip(
                          avatar: Icon(
                            absent
                                ? Icons.remove_circle_outline
                                : passed
                                    ? Icons.check_circle
                                    : Icons.cancel,
                            size: 18,
                          ),
                          label: Text(
                            absent
                                ? "Absent"
                                : passed
                                    ? "Pass"
                                    : "Fail",
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Card(
        elevation: 0,
        color: result.isPass
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                result.isPass ? Icons.emoji_events : Icons.warning_amber,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  result.isPass
                      ? "Congratulations! Student has successfully passed."
                      : "Student has not met the passing criteria.",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              context,
              "Total",
              "${result.totalObtained}/${result.totalMaximum}",
              Icons.calculate_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _summaryCard(
              context,
              "Percentage",
              "${result.percentage.toStringAsFixed(1)}%",
              Icons.percent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _summaryCard(
              context,
              result.isPass ? "PASS" : "FAIL",
              "",
              result.isPass ? Icons.check_circle : Icons.cancel,
              color: result.isPass ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Card(
      elevation: 0,
      color: color?.withValues(alpha: 0.1) ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Divider(),
                Text(
                  "Class Teacher",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                const Divider(),
                Text(
                  "Principal",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}