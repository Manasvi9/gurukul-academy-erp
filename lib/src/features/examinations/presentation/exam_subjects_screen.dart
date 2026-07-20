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
  const ExamSubjectsScreen({
    required this.examId,
    required this.exam,
    super.key,
  });
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
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Exam Subjects"),
            Text(
              widget.exam.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Results Published • Editing Locked",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ResponsivePage(
              maxWidth: 950,
              child: AppAsyncView<List<ExamSubject>>(
                value: examSubjectsAsync,
                data: (subjects) {
                  return AppAsyncView<List<AcademicSubject>>(
                    value: academicSubjectsAsync,
                    data: (allSubjects) {
                      if (subjects.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 72,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                "No Subjects Added",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add subjects to begin entering marks.",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
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
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                          academicSubject.name.characters.first,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              academicSubject.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              academicSubject.code ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => context.push(
                                          '/exams/${widget.examId}/subjects/${subject.id}/marks',
                                          extra: {
                                            'exam': widget.exam,
                                            'subject': subject,
                                          },
                                        ),
                                        icon: const Icon(Icons.edit_note),
                                        label: const Text("Marks"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(Icons.flag),
                                        label: Text(
                                          "Max ${subject.maximumMarks}",
                                        ),
                                      ),
                                      Chip(
                                        avatar: const Icon(Icons.check),
                                        label: Text(
                                          "Pass ${subject.passingMarks}",
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isPublished)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _showSubjectDialog(
                                                subject: subject,),
                                            icon: const Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _deleteSubject(subject.id),
                                            icon: const Icon(
                                                Icons.delete_outline,),
                                          ),
                                        ],
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
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text("Add Subject"),
              onPressed: () => _showSubjectDialog(),
            ),
    );
  }

  Future<void> _deleteSubject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text("Delete Subject"),
          ],
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
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
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                TextFormField(
                  controller: maxMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Marks',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                      ? 'Invalid marks'
                      : null,
                ),
                TextFormField(
                  controller: passMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Passing Marks',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
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
            OutlinedButton(
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
              child: Text(
                subject == null ? "Add Subject" : "Save Changes",
              ),
            ),
          ],
        );
      },
    );
  }
}