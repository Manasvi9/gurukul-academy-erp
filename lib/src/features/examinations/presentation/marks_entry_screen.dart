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
  const MarksEntryScreen({required this.examSubjectId, required this.exam, required this.subject, super.key});
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
    final studentsAsync = ref.watch(studentListProvider(StudentListRequest(
      academicYearId: widget.exam.academicYearId,
      classId: widget.exam.classId,
      sectionId: widget.exam.sectionId,
    ),),);
    final existingMarksAsync = ref.watch(examMarksProvider(widget.examSubjectId));

    return Scaffold(
      appBar: AppBar(title: Text('Enter Marks: ${widget.exam.name}')),
      body: ResponsivePage(
        maxWidth: 800,
        child: AppAsyncView<List<StudentSummary>>(
          value: studentsAsync,
          data: (students) {
            return AppAsyncView<List<ExamMark>>(
              value: existingMarksAsync,
              data: (existingMarks) {
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
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

                    return Card(
                      margin: const EdgeInsets.all(AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${student.rollNumber ?? ''}')),
                        title: Text(student.name),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _marksControllers[student.id],
                                decoration: const InputDecoration(labelText: 'Marks'),
                                keyboardType: TextInputType.number,
                                enabled: !_absentStates[student.id]!,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Checkbox(
                              value: _absentStates[student.id],
                              onChanged: (value) => setState(() => _absentStates[student.id] = value!),
                            ),
                            const Text('Absent'),
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
      bottomNavigationBar: BottomAppBar(
        child: FilledButton(
          onPressed: _isSaving ? null : _saveMarks,
          child: const Text('Save Marks'),
        ),
      ),
    );
  }

  Future<void> _saveMarks() async {
    final marks = <ExamMark>[];
    for (final studentId in _marksControllers.keys) {
      if (_absentStates[studentId]!) {
        marks.add(ExamMark(
          studentId: studentId,
          examSubjectId: widget.examSubjectId,
          marks: null,
          isFinal: true,
        ),);
      } else {
        final marksValue = double.tryParse(_marksControllers[studentId]!.text);
        if (marksValue == null ||
            marksValue < 0 ||
            marksValue > widget.subject.maximumMarks) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Invalid marks for a student.'),
          ),);
          return;
        }
        marks.add(ExamMark(
          studentId: studentId,
          examSubjectId: widget.examSubjectId,
          marks: marksValue,
          isFinal: true,
        ),);
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
          content: Text('Marks saved successfully'),
        ),
      );
      context.pop();
    }
  }
}
