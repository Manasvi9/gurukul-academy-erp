import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../students/domain/entities/student_summary.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/exam_subject.dart';
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
      appBar: AppBar(title: const Text('Report Card')),
      body: ResponsivePage(
        maxWidth: 800,
        child: AppAsyncView<List<({ExamSubject subject, ExamMark mark})>>(
          value: marksAsync,
          data: (marks) {
            return Column(
              children: [
                _buildHeader(context),
                _buildStudentDetails(context),
                _buildMarksTable(context, marks),
                _buildSummary(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text('Gurukul Academy',
                style: Theme.of(context).textTheme.headlineSmall,),
            const SizedBox(height: AppSpacing.sm),
            Text(exam.name, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${student.name}',
                style: Theme.of(context).textTheme.bodyLarge,),
            Text('Roll: ${student.rollNumber}',
                style: Theme.of(context).textTheme.bodyLarge,),
            Text(
              'Class: ${student.className} - ${student.sectionName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksTable(BuildContext context,
      List<({ExamSubject subject, ExamMark mark})> marks,) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Max')),
          DataColumn(label: Text('Obt')),
          DataColumn(
            label: Text('Result'),
          ),
        ],
        rows: marks.map(
          (m) {
            final mark = m.mark;
            final subject = m.subject;
            final isAbsent = mark.isFinal && mark.marks == null;
            final isPass =
                !isAbsent && (mark.marks ?? 0) >= subject.passingMarks;
            return DataRow(
              cells: [
                DataCell(Text(subject.subjectId)),
                DataCell(Text('${subject.maximumMarks}')),
                DataCell(Text(isAbsent ? 'AB' : '${mark.marks ?? '-'}')),
                DataCell(Text(isPass ? 'Pass' : 'Fail')),
              ],
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Total: ${result.totalObtained}/${result.totalMaximum}'),
            Text('Percentage: ${result.percentage.toStringAsFixed(1)}%'),
            Text(
              'Result: ${result.isPass ? 'Pass' : 'Fail'}',
            ),
          ],
        ),
      ),
    );
  }
}
