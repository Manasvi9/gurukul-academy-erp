import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/premium_app_bar.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/academic_class.dart';
import '../../domain/entities/academic_subject.dart';
import '../providers/academic_structure_providers.dart';

final class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(academicSubjectsProvider);
    final classes = ref.watch(activeAcademicClassesProvider);
    return Scaffold(
      appBar: PremiumAppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            tooltip: 'Classes',
            onPressed: () => context.go(AppRoute.classes.path),
            icon: const Icon(Icons.class_outlined),
          ),
          IconButton(
            tooltip: 'Sections',
            onPressed: () => context.go(AppRoute.sections.path),
            icon: const Icon(Icons.view_week_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: classes.when(
          data: (items) =>
              items.isEmpty ? null : () => _showForm(context, ref, items),
          loading: () => null,
          error: (_, __) => null,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add subject'),
      ),
      body: ResponsivePage(
        maxWidth: 1100,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search subjects or codes',
                ),
                onChanged: (value) =>
                    ref.read(subjectSearchProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AppAsyncView(
                  value: subjects,
                  data: (items) => classes.when(
                    data: (classItems) {
                      final classNames = {
                        for (final item in classItems) item.id: item.name,
                      };
                      return items.isEmpty
                          ? const AppEmptyView(
                              title: 'No subjects',
                              message:
                                  'Add a subject and choose its applicable classes.',
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) => constraints
                                          .maxWidth <
                                      720
                                  ? ListView(
                                      children: items
                                          .map(
                                            (item) => ListTile(
                                              title: Text(item.name),
                                              subtitle: Text(
                                                _subjectDetail(
                                                  item,
                                                  classNames,
                                                ),
                                              ),
                                              trailing: _SubjectActions(
                                                item: item,
                                                onEdit: () => _showForm(
                                                  context,
                                                  ref,
                                                  classItems,
                                                  item,
                                                ),
                                                onArchive: () => _archive(
                                                  context,
                                                  ref,
                                                  item,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                            label: Text('Subject name'),
                                          ),
                                          DataColumn(label: Text('Code')),
                                          DataColumn(
                                            label: Text('Applicable classes'),
                                          ),
                                          DataColumn(label: Text('Order')),
                                          DataColumn(label: Text('Status')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: items
                                            .map(
                                              (item) => DataRow(
                                                cells: [
                                                  DataCell(Text(item.name)),
                                                  DataCell(
                                                    Text(item.code ?? '-'),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 240,
                                                      child: Text(
                                                        _classLabels(
                                                          item,
                                                          classNames,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${item.displayOrder}',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item.isActive
                                                          ? 'Active'
                                                          : 'Inactive',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    _SubjectActions(
                                                      item: item,
                                                      onEdit: () => _showForm(
                                                        context,
                                                        ref,
                                                        classItems,
                                                        item,
                                                      ),
                                                      onArchive: () => _archive(
                                                        context,
                                                        ref,
                                                        item,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                            );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const AppEmptyView(
                      title: 'Classes unavailable',
                      message:
                          'Subjects need class options before they can be managed.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subjectDetail(AcademicSubject item, Map<String, String> classNames) {
    final code =
        item.code == null || item.code!.isEmpty ? 'No code' : item.code!;
    return '$code • ${_classLabels(item, classNames)} • ${item.isActive ? 'Active' : 'Inactive'}';
  }

  String _classLabels(AcademicSubject item, Map<String, String> classNames) {
    return item.classIds
        .map((id) => classNames[id] ?? 'Archived class')
        .join(', ');
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref,
    List<AcademicClass> classes, [
    AcademicSubject? item,
  ]) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: item?.name);
    final code = TextEditingController(text: item?.code);
    final order = TextEditingController(text: '${item?.displayOrder ?? 0}');
    final selected = {...?item?.classIds};
    var isActive = item?.isActive ?? true;
    var showClassError = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Add subject' : 'Edit subject'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: name,
                      decoration:
                          const InputDecoration(labelText: 'Subject name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Subject name is required.'
                              : null,
                    ),
                    TextFormField(
                      controller: code,
                      decoration: const InputDecoration(
                        labelText: 'Subject code (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: order,
                      decoration:
                          const InputDecoration(labelText: 'Display order'),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value ?? '') == null
                          ? 'Enter a valid display order.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Applicable classes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: classes
                          .map(
                            (schoolClass) => FilterChip(
                              label: Text(schoolClass.name),
                              selected: selected.contains(schoolClass.id),
                              onSelected: (value) => setState(() {
                                if (value) {
                                  selected.add(schoolClass.id);
                                } else {
                                  selected.remove(schoolClass.id);
                                }
                                showClassError = false;
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    if (showClassError)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Choose at least one applicable class.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active status'),
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
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
                if (!key.currentState!.validate()) return;
                if (selected.isEmpty) {
                  setState(() => showClassError = true);
                  return;
                }
                try {
                  await ref
                      .read(academicStructureRepositoryProvider)
                      .saveSubject(
                        id: item?.id,
                        name: name.text,
                        code: code.text,
                        classIds: selected.toList(),
                        displayOrder: int.parse(order.text),
                        isActive: isActive,
                      );
                  ref.invalidate(academicSubjectsProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    _message(context, 'Subject saved successfully.');
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

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    AcademicSubject item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive subject?'),
        content:
            Text('${item.name} will no longer be available for new records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(academicStructureRepositoryProvider)
          .archiveSubject(item.id);
      ref.invalidate(academicSubjectsProvider);
      if (context.mounted) _message(context, 'Subject archived successfully.');
    } catch (error) {
      if (context.mounted) _message(context, error.toString(), error: true);
    }
  }

  void _message(BuildContext context, String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: error ? Colors.red : null),
    );
  }
}

final class _SubjectActions extends StatelessWidget {
  const _SubjectActions({
    required this.item,
    required this.onEdit,
    required this.onArchive,
  });

  final AcademicSubject item;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit ${item.name}',
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Archive ${item.name}',
            onPressed: onArchive,
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      );
}
