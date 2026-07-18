import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/academic_class.dart';
import '../providers/academic_structure_providers.dart';

final class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(academicClassesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: [
          IconButton(
            tooltip: 'Sections',
            onPressed: () => context.go(AppRoute.sections.path),
            icon: const Icon(Icons.view_week_outlined),
          ),
          IconButton(
            tooltip: 'Subjects',
            onPressed: () => context.go(AppRoute.subjects.path),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search classes',
                ),
                onChanged: (value) =>
                    ref.read(classSearchProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AppAsyncView(
                  value: classes,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No classes',
                          message:
                              'Add a class to begin building the academic structure.',
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) => constraints
                                      .maxWidth <
                                  640
                              ? ListView(
                                  children: items
                                      .map(
                                        (item) => ListTile(
                                          title: Text(item.name),
                                          subtitle: Text(
                                            'Order ${item.displayOrder} • ${item.isActive ? 'Active' : 'Inactive'}',
                                          ),
                                          trailing: _ClassActions(
                                            item: item,
                                            onEdit: () =>
                                                _showForm(context, ref, item),
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
                                      DataColumn(label: Text('Class name')),
                                      DataColumn(label: Text('Display order')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: items
                                        .map(
                                          (item) => DataRow(
                                            cells: [
                                              DataCell(Text(item.name)),
                                              DataCell(
                                                Text('${item.displayOrder}'),
                                              ),
                                              DataCell(
                                                Text(
                                                  item.isActive
                                                      ? 'Active'
                                                      : 'Inactive',
                                                ),
                                              ),
                                              DataCell(
                                                _ClassActions(
                                                  item: item,
                                                  onEdit: () => _showForm(
                                                    context,
                                                    ref,
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
    WidgetRef ref, [
    AcademicClass? item,
  ]) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: item?.name);
    final order = TextEditingController(text: '${item?.displayOrder ?? 0}');
    var isActive = item?.isActive ?? true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Add class' : 'Edit class'),
          content: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Class name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Class name is required.'
                        : null,
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
                  await ref.read(academicStructureRepositoryProvider).saveClass(
                        id: item?.id,
                        name: name.text,
                        displayOrder: int.parse(order.text),
                        isActive: isActive,
                      );
                  ref.invalidate(academicClassesProvider);
                  ref.invalidate(activeAcademicClassesProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    _message(context, 'Class saved successfully.');
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
    AcademicClass item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive class?'),
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
      await ref.read(academicStructureRepositoryProvider).archiveClass(item.id);
      ref.invalidate(academicClassesProvider);
      ref.invalidate(activeAcademicClassesProvider);
      ref.invalidate(academicSectionsProvider);
      if (context.mounted) _message(context, 'Class archived successfully.');
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

final class _ClassActions extends StatelessWidget {
  const _ClassActions({
    required this.item,
    required this.onEdit,
    required this.onArchive,
  });

  final AcademicClass item;
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
