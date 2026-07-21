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
import '../../domain/entities/academic_section.dart';
import '../providers/academic_structure_providers.dart';

final class SectionsScreen extends ConsumerWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(academicSectionsProvider);
    final classes = ref.watch(activeAcademicClassesProvider);
    final filter = ref.watch(sectionClassFilterProvider);
    return Scaffold(
      appBar: PremiumAppBar(
        title: const Text('Sections'),
        actions: [
          IconButton(
            tooltip: 'Classes',
            onPressed: () => context.go(AppRoute.classes.path),
            icon: const Icon(Icons.class_outlined),
          ),
          IconButton(
            tooltip: 'Subjects',
            onPressed: () => context.go(AppRoute.subjects.path),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: classes.when(
          data: (items) => () => _showForm(context, ref, items),
          loading: () => null,
          error: (_, __) => null,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add section'),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              classes.when(
                data: (items) => DropdownButtonFormField<String?>(
                  initialValue: filter,
                  decoration:
                      const InputDecoration(labelText: 'Filter by class'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All classes'),
                    ),
                    ...items.map(
                      (item) => DropdownMenuItem<String?>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(sectionClassFilterProvider.notifier)
                      .state = value,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) =>
                    const Text('Unable to load classes for filtering.'),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AppAsyncView(
                  value: sections,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No sections',
                          message: 'Add a section for a class to get started.',
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) => constraints
                                      .maxWidth <
                                  680
                              ? ListView(
                                  children: items
                                      .map(
                                        (item) => ListTile(
                                          title: Text(
                                            '${item.className} – ${item.name}',
                                          ),
                                          subtitle: Text(
                                            '${item.capacity == null ? 'No capacity set' : 'Capacity ${item.capacity}'} • ${item.isActive ? 'Active' : 'Inactive'}',
                                          ),
                                          trailing: _SectionActions(
                                            item: item,
                                            onEdit: () => classes.whenData(
                                              (values) => _showForm(
                                                context,
                                                ref,
                                                values,
                                                item,
                                              ),
                                            ),
                                            onArchive: () =>
                                                _archive(context, ref, item),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Class')),
                                      DataColumn(label: Text('Section')),
                                      DataColumn(label: Text('Capacity')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: items
                                        .map(
                                          (item) => DataRow(
                                            cells: [
                                              DataCell(Text(item.className)),
                                              DataCell(Text(item.name)),
                                              DataCell(
                                                Text(
                                                  item.capacity?.toString() ??
                                                      '-',
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
                                                _SectionActions(
                                                  item: item,
                                                  onEdit: () =>
                                                      classes.whenData(
                                                    (values) => _showForm(
                                                      context,
                                                      ref,
                                                      values,
                                                      item,
                                                    ),
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
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref,
    List<AcademicClass> classes, [
    AcademicSection? item,
  ]) async {
    final key = GlobalKey<FormState>();
    var classId = item?.classId ?? classes.first.id;
    final name = TextEditingController(text: item?.name);
    final capacity = TextEditingController(text: item?.capacity?.toString());
    var isActive = item?.isActive ?? true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Add section' : 'Edit section'),
          content: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: classId.isEmpty ? null : classId,
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (value) =>
                        value == null ? 'Class is required.' : null,
                    items: classes
                        .map(
                          (schoolClass) => DropdownMenuItem(
                            value: schoolClass.id,
                            child: Text(schoolClass.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => classId = value!),
                  ),
                  TextFormField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: 'Section name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Section name is required.'
                        : null,
                  ),
                  TextFormField(
                    controller: capacity,
                    decoration:
                        const InputDecoration(labelText: 'Capacity (optional)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final parsed = int.tryParse(value);
                      return parsed == null || parsed <= 0
                          ? 'Capacity must be a positive number.'
                          : null;
                    },
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!key.currentState!.validate()) return;
                try {
                  await ref
                      .read(academicStructureRepositoryProvider)
                      .saveSection(
                        id: item?.id,
                        classId: classId,
                        name: name.text,
                        capacity: int.tryParse(capacity.text),
                        isActive: isActive,
                      );
                  ref.invalidate(academicSectionsProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    _message(context, 'Section saved successfully.');
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
    AcademicSection item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive section?'),
        content: Text(
          '${item.className} – ${item.name} will no longer be available for new records.',
        ),
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
          .archiveSection(item.id);
      ref.invalidate(academicSectionsProvider);
      if (context.mounted) _message(context, 'Section archived successfully.');
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

final class _SectionActions extends StatelessWidget {
  const _SectionActions({
    required this.item,
    required this.onEdit,
    required this.onArchive,
  });

  final AcademicSection item;
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
