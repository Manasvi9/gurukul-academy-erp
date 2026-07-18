import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../academic_structure/domain/entities/academic_section.dart';
import '../../../academic_structure/presentation/providers/academic_structure_providers.dart';
import '../../domain/entities/homework_item.dart';
import '../providers/homework_providers.dart';

final class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homework = ref.watch(homeworkListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Homework Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Create homework'),
      ),
      body: ResponsivePage(
        maxWidth: 1050,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppAsyncView(
            value: homework,
            data: (items) => items.isEmpty
                ? const AppEmptyView(
                    title: 'No homework assigned',
                    message: 'Create homework for a class and section.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => constraints.maxWidth <
                            680
                        ? ListView(
                            children: items
                                .map(
                                  (item) => ListTile(
                                    title: Text(item.subjectName),
                                    subtitle: Text(
                                      '${item.className} – ${item.sectionName}\nDue ${_dateLabel(item.dueDate)}',
                                    ),
                                    isThreeLine: true,
                                    trailing: _HomeworkActions(
                                      onEdit: () =>
                                          _showForm(context, ref, item),
                                      onDelete: () =>
                                          _delete(context, ref, item),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Subject')),
                                DataColumn(label: Text('Class / Section')),
                                DataColumn(label: Text('Due date')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: items
                                  .map(
                                    (item) => DataRow(
                                      cells: [
                                        DataCell(Text(item.subjectName)),
                                        DataCell(
                                          Text(
                                            '${item.className} – ${item.sectionName}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(_dateLabel(item.dueDate)),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 300,
                                            child: Text(
                                              item.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          _HomeworkActions(
                                            onEdit: () =>
                                                _showForm(context, ref, item),
                                            onDelete: () =>
                                                _delete(context, ref, item),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, [
    HomeworkItem? item,
  ]) async {
    final academicRepository = ref.read(academicStructureRepositoryProvider);
    final classes = await academicRepository.activeClasses();
    final subjects = await academicRepository.subjects('');
    final academicYear =
        await ref.read(homeworkRepositoryProvider).activeAcademicYearId();
    if (!context.mounted ||
        classes.isEmpty ||
        subjects.isEmpty ||
        academicYear == null) {
      if (context.mounted) {
        _message(
          context,
          'An active academic year, class, and subject are required.',
          error: true,
        );
      }
      return;
    }
    final key = GlobalKey<FormState>();
    var classId = item?.classId ?? classes.first.id;
    var sectionId = item?.sectionId;
    var subjectId = item?.subjectId ?? subjects.first.id;
    var dueDate = item?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    var sectionsFuture = academicRepository.sections(classId);
    final description = TextEditingController(text: item?.description);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Create homework' : 'Edit homework'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: classes
                          .map(
                            (schoolClass) => DropdownMenuItem(
                              value: schoolClass.id,
                              child: Text(schoolClass.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        classId = value!;
                        sectionId = null;
                        sectionsFuture = academicRepository.sections(classId);
                      }),
                    ),
                    FutureBuilder<List<AcademicSection>>(
                      future: sectionsFuture,
                      builder: (context, snapshot) {
                        final sections =
                            snapshot.data ?? const <AcademicSection>[];
                        if (sectionId != null &&
                            !sections.any((entry) => entry.id == sectionId)) {
                          sectionId = null;
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: sectionId,
                          decoration:
                              const InputDecoration(labelText: 'Section'),
                          items: sections
                              .map(
                                (section) => DropdownMenuItem(
                                  value: section.id,
                                  child: Text(section.name),
                                ),
                              )
                              .toList(),
                          validator: (value) =>
                              value == null ? 'Section is required.' : null,
                          onChanged: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? null
                              : (value) => setState(() => sectionId = value),
                        );
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: subjectId,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject.id,
                              child: Text(subject.name),
                            ),
                          )
                          .toList(),
                      validator: (value) =>
                          value == null ? 'Subject is required.' : null,
                      onChanged: (value) => setState(() => subjectId = value!),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due date'),
                      subtitle: Text(_dateLabel(dueDate)),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                        );
                        if (picked != null) {
                          setState(() => dueDate = picked);
                        }
                      },
                    ),
                    TextFormField(
                      controller: description,
                      minLines: 3,
                      maxLines: 6,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Description is required.'
                              : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!key.currentState!.validate()) {
                  return;
                }
                try {
                  await ref.read(homeworkRepositoryProvider).save(
                        id: item?.id,
                        academicYearId: academicYear,
                        classId: classId,
                        sectionId: sectionId!,
                        subjectId: subjectId,
                        dueDate: dueDate,
                        description: description.text,
                      );
                  ref.invalidate(homeworkListProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    _message(context, 'Homework saved successfully.');
                  }
                } catch (error) {
                  if (context.mounted) {
                    _message(context, error.toString(), error: true);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    HomeworkItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete homework?'),
        content: Text(
          'Delete ${item.subjectName} homework for ${item.className} – ${item.sectionName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(homeworkRepositoryProvider).delete(item.id);
      ref.invalidate(homeworkListProvider);
      if (context.mounted) {
        _message(context, 'Homework deleted successfully.');
      }
    } catch (error) {
      if (context.mounted) {
        _message(context, error.toString(), error: true);
      }
    }
  }

  static String _dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static void _message(
    BuildContext context,
    String text, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: error ? Colors.red : null),
    );
  }
}

final class _HomeworkActions extends StatelessWidget {
  const _HomeworkActions({
    required this.onEdit,
    required this.onDelete,
  });
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      );
}
