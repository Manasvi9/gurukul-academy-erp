import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gurukul_academy_erp/src/core/theme/app_spacing.dart';
import 'package:gurukul_academy_erp/src/features/academic_structure/presentation/providers/academic_structure_providers.dart';
import 'package:gurukul_academy_erp/src/features/authentication/domain/entities/auth_role.dart';
import 'package:gurukul_academy_erp/src/features/authentication/presentation/providers/auth_providers.dart';
import 'package:gurukul_academy_erp/src/features/timetable/domain/entities/timetable_entry.dart';
import 'package:gurukul_academy_erp/src/features/timetable/presentation/timetable_providers.dart';
import 'package:gurukul_academy_erp/src/features/timetable/presentation/widgets/timetable_entry_form.dart';
import 'package:gurukul_academy_erp/src/shared/widgets/app_async_view.dart';
import 'package:gurukul_academy_erp/src/shared/widgets/app_empty_view.dart';
import 'package:gurukul_academy_erp/src/shared/widgets/responsive_page.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(timetableEntriesProvider);
    final authState = ref.watch(authControllerProvider);
    final role = authState.user?.role;
    final canManage = role == AuthRole.systemAdmin ||
        role == AuthRole.director ||
        role == AuthRole.principal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Period'),
            )
          : null,
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              if (canManage || role == AuthRole.teacher)
                _buildFilters(context, ref, canManage),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AppAsyncView(
                  value: entries,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No timetable entries',
                          message: 'No periods match the current view.',
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final entry = items[index];
                            return _TimetableCard(
                              entry: entry,
                              canManage: canManage,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    bool canManage,
  ) {
    final classes = ref.watch(activeAcademicClassesProvider);
    final teachers = ref.watch(timetableTeachersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                if (canManage) ...[
                  Expanded(
                    child: classes.when(
                      data: (items) => DropdownButtonFormField<String?>(
                        initialValue: ref.watch(timetableClassFilterProvider),
                        decoration:
                            const InputDecoration(labelText: 'Filter Class'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Classes'),
                          ),
                          ...items.map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref
                              .read(timetableClassFilterProvider.notifier)
                              .set(value);
                          ref
                              .read(timetableSectionFilterProvider.notifier)
                              .set(null);
                        },
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ref.watch(academicSectionsProvider).when(
                          data: (items) {
                            final classId =
                                ref.watch(timetableClassFilterProvider);
                            final filtered = classId == null
                                ? <DropdownMenuItem<String?>>[]
                                : items
                                    .where((s) => s.classId == classId)
                                    .map(
                                      (item) => DropdownMenuItem<String?>(
                                        value: item.id,
                                        child: Text(item.name),
                                      ),
                                    )
                                    .toList();
                            return DropdownButtonFormField<String?>(
                              initialValue:
                                  ref.watch(timetableSectionFilterProvider),
                              decoration: const InputDecoration(
                                labelText: 'Filter Section',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Sections'),
                                ),
                                ...filtered,
                              ],
                              onChanged: classId == null
                                  ? null
                                  : (value) => ref
                                      .read(
                                        timetableSectionFilterProvider.notifier,
                                      )
                                      .set(value),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const SizedBox(),
                        ),
                  ),
                ],
                if (canManage) const SizedBox(width: AppSpacing.sm),
                if (canManage)
                  Expanded(
                    child: teachers.when(
                      data: (items) => DropdownButtonFormField<String?>(
                        initialValue: ref.watch(timetableTeacherFilterProvider),
                        decoration:
                            const InputDecoration(labelText: 'Filter Teacher'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Teachers'),
                          ),
                          ...items.map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => ref
                            .read(timetableTeacherFilterProvider.notifier)
                            .set(value),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, [TimetableEntry? entry]) {
    showDialog<void>(
      context: context,
      builder: (context) => TimetableEntryForm(entry: entry),
    );
  }
}

class _TimetableCard extends ConsumerWidget {
  const _TimetableCard({
    required this.entry,
    required this.canManage,
  });

  final TimetableEntry entry;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text('${entry.dayLabel} • ${entry.startTime}–${entry.endTime}'),
        subtitle: Text(
          '${entry.subjectName} • ${entry.teacherName}\n'
          '${entry.className} ${entry.sectionName}${entry.room == null ? '' : ' • Room ${entry.room}'}',
        ),
        isThreeLine: true,
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    showDialog<void>(
                      context: context,
                      builder: (context) => TimetableEntryForm(entry: entry),
                    );
                  } else if (action == 'delete') {
                    _delete(context, ref, entry.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Period'),
        content: const Text('Are you sure you want to delete this period?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(timetableRepositoryProvider).delete(id);
        ref.invalidate(timetableEntriesProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}
