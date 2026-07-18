import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../academic_structure/domain/entities/academic_subject.dart';
import '../../academic_structure/presentation/providers/academic_structure_providers.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_subject.dart';
import 'exam_providers.dart';

final class ExamSubjectsScreen extends ConsumerStatefulWidget {
  const ExamSubjectsScreen({required this.examId, required this.exam, super.key});
  final String examId;
  final Exam exam;

  @override
  ConsumerState<ExamSubjectsScreen> createState() => _ExamSubjectsScreenState();
}

final class _ExamSubjectsScreenState extends ConsumerState<ExamSubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final examSubjectsAsync = ref.watch(examSubjectsProvider(widget.examId));
    final academicSubjectsAsync = ref.watch(academicSubjectsProvider);
    final isPublished = widget.exam.status == ExamStatus.published;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () => context.pushNamed(
              'examResults',
              extra: widget.exam,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isPublished)
            Container(
              color: Colors.amber.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.amber),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Results Published - Editing Locked',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ResponsivePage(
              maxWidth: 800,
              child: AppAsyncView<List<ExamSubject>>(
                value: examSubjectsAsync,
                data: (subjects) {
                  return AppAsyncView<List<AcademicSubject>>(
                    value: academicSubjectsAsync,
                    data: (allSubjects) {
                      if (subjects.isEmpty) {
                        return const Center(child: Text('No subjects added yet.'));
                      }
                      return ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          final academicSubject = allSubjects.firstWhere(
                            (s) => s.id == subject.subjectId,
                            orElse: () => AcademicSubject(
                              id: subject.subjectId,
                              name: 'Unknown',
                              code: null,
                              classIds: [],
                              displayOrder: 0,
                              isActive: true,
                            ),
                          );
                          return Card(
                            margin: const EdgeInsets.all(AppSpacing.sm),
                            child: ListTile(
                              title: Text(academicSubject.name),
                              subtitle: Text(
                                'Max: ${subject.maximumMarks}, Pass: ${subject.passingMarks}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isPublished) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          _showSubjectDialog(subject: subject),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteSubject(subject.id),
                                    ),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.edit_note),
                                    onPressed: () => context.push(
                                      '/exams/${widget.examId}/subjects/${subject.id}/marks',
                                      extra: {
                                        'exam': widget.exam,
                                        'subject': subject,
                                      },
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
          ),
        ],
      ),
      floatingActionButton: isPublished
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showSubjectDialog(),
            ),
    );
  }

  Future<void> _deleteSubject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(examSubjectDeleteProvider)(widget.examId, id);
    }
  }

  Future<void> _showSubjectDialog({ExamSubject? subject}) async {
    final formKey = GlobalKey<FormState>();
    String? selectedSubjectId = subject?.subjectId;
    final maxMarksController =
        TextEditingController(text: subject?.maximumMarks.toString());
    final passMarksController =
        TextEditingController(text: subject?.passingMarks.toString());

    // Need list of all subjects
    final allSubjects = await ref.read(academicSubjectsProvider.future);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(subject == null ? 'Add Subject' : 'Edit Subject'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedSubjectId,
                  items: allSubjects
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedSubjectId = value,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                TextFormField(
                  controller: maxMarksController,
                  decoration: const InputDecoration(labelText: 'Maximum Marks'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (double.tryParse(value ?? '') ?? 0) <= 0
                          ? 'Invalid marks'
                          : null,
                ),
                TextFormField(
                  controller: passMarksController,
                  decoration: const InputDecoration(labelText: 'Passing Marks'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (double.tryParse(value ?? '') ?? -1) < 0
                          ? 'Invalid marks'
                          : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final values = {
                  'exam_id': widget.examId,
                  'subject_id': selectedSubjectId,
                  'maximum_marks': double.parse(maxMarksController.text),
                  'passing_marks': double.parse(passMarksController.text),
                };

                if (subject == null) {
                  await ref.read(examSubjectAddProvider)(
                    widget.examId,
                    values,
                  );
                } else {
                  await ref.read(examSubjectUpdateProvider)(
                    widget.examId,
                    subject.id,
                    values,
                  );
                }

                if (mounted && dialogContext.mounted) {
                  dialogContext.pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
