import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../students/domain/entities/student_summary.dart';
import '../../students/presentation/providers/student_providers.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/exam_subject.dart';
import 'exam_providers.dart';

final class MarksEntryScreen extends ConsumerStatefulWidget {
  const MarksEntryScreen({
    required this.examSubjectId,
    required this.exam,
    required this.subject,
    super.key,
  });
  final String examSubjectId;
  final Exam exam;
  final ExamSubject subject;

  @override
  ConsumerState<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

final class _MarksEntryScreenState extends ConsumerState<MarksEntryScreen> {
  final _marksControllers = <String, TextEditingController>{};
  final _absentStates = <String, bool>{};
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(
      studentListProvider(
        StudentListRequest(
          academicYearId: widget.exam.academicYearId,
          classId: widget.exam.classId,
          sectionId: widget.exam.sectionId,
        ),
      ),
    );
    final existingMarksAsync =
        ref.watch(examMarksProvider(widget.examSubjectId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject.subjectId), // Using subjectId fallback as domain structural item
            Text(
              widget.exam.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ResponsivePage(
        maxWidth: 950,
        child: AppAsyncView<List<StudentSummary>>(
          value: studentsAsync,
          data: (students) {
            return AppAsyncView<List<ExamMark>>(
              value: existingMarksAsync,
              data: (existingMarks) {
                // Pre-populate structural mapping collections
                for (final student in students) {
                  final existingMark = existingMarks.firstWhere(
                    (m) => m.studentId == student.id,
                    orElse: () => ExamMark(
                      studentId: student.id,
                      examSubjectId: widget.examSubjectId,
                      marks: null,
                      isFinal: false,
                    ),
                  );

                  _marksControllers.putIfAbsent(
                    student.id,
                    () => TextEditingController(
                      text: existingMark.marks?.toString() ?? '',
                    ),
                  );
                  _absentStates.putIfAbsent(
                    student.id,
                    () => existingMark.marks == null && existingMark.isFinal,
                  );
                }

                // Metric Calculations for real-time progress card visualization
                final enteredCount = _marksControllers.values
                    .where((c) => c.text.isNotEmpty)
                    .length;
                final absentCount = _absentStates.values.where((e) => e).length;
                final remainingCount = students.length - enteredCount - absentCount;

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: students.length + 1, // Added 1 for the Header Summary Card
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox(height: AppSpacing.md)
                      : const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Progress Metric Summary Presentation Card
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricItem(context, "Total Students", "${students.length}"),
                              _buildMetricItem(context, "Entered", "$enteredCount", color: Colors.green),
                              _buildMetricItem(context, "Absent", "$absentCount", color: Colors.orange),
                              _buildMetricItem(context, "Remaining", "$remainingCount", color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      );
                    }

                    // Adjust offset index down by 1 to get standard item index referencing students array
                    final student = students[index - 1];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  child: Text(
                                    "${student.rollNumber ?? '-'}",
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        "Roll No. ${student.rollNumber ?? '-'}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: _absentStates[student.id],
                                  onChanged: (value) {
                                    setState(() {
                                      _absentStates[student.id] = value!;
                                      if (value) {
                                        _marksControllers[student.id]?.clear();
                                      }
                                    });
                                  },
                                ),
                                const Text("Absent"),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _marksControllers[student.id],
                              enabled: !_absentStates[student.id]!,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => setState(() {}), // Update counts interactively
                              decoration: InputDecoration(
                                labelText:
                                    "Marks (Max ${widget.subject.maximumMarks})",
                                prefixIcon:
                                    const Icon(Icons.edit_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveMarks,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isSaving ? "Saving..." : "Save Marks",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _saveMarks() async {
    final marks = <ExamMark>[];
    for (final studentId in _marksControllers.keys) {
      if (_absentStates[studentId]!) {
        marks.add(
          ExamMark(
            studentId: studentId,
            examSubjectId: widget.examSubjectId,
            marks: null,
            isFinal: true,
          ),
        );
      } else {
        final textInput = _marksControllers[studentId]!.text.trim();
        if (textInput.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter marks or mark as absent for all students.'),
            ),
          );
          return;
        }

        final marksValue = double.tryParse(textInput);
        if (marksValue == null ||
            marksValue < 0 ||
            marksValue > widget.subject.maximumMarks) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter valid marks between 0 and ${widget.subject.maximumMarks}.'),
            ),
          );
          return;
        }
        marks.add(
          ExamMark(
            studentId: studentId,
            examSubjectId: widget.examSubjectId,
            marks: marksValue,
            isFinal: true,
          ),
        );
      }
    }

    setState(() => _isSaving = true);
    await ref.read(examMarksSaveProvider)(
      widget.examSubjectId,
      marks,
      true,
    );
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marks saved successfully ✅'),
        ),
      );
      context.pop();
    }
  }
}