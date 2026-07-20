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
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timetable'),
            Text(
              'Weekly schedules and period assignments',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Period'),
            )
          : null,
      body: ResponsivePage(
        maxWidth: 950,
        child: AppAsyncView(
          value: entries,
          data: (items) {
            final activeClasses = ref.watch(activeAcademicClassesProvider).asData?.value.length ?? 0;
            final activeTeachers = ref.watch(timetableTeachersProvider).asData?.value.length ?? 0;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(timetableEntriesProvider);
                await ref.read(timetableEntriesProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.isEmpty ? 2 : items.length + 2,
                separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(context, "Total Periods", "${items.length}"),
                            _buildStatItem(context, "Active Classes", "$activeClasses"),
                            _buildStatItem(context, "Teachers Roster", "$activeTeachers"),
                          ],
                        ),
                      ),
                    );
                  }

                  if (index == 1) {
                    if (canManage || role == AuthRole.teacher) {
                      return _buildFilters(context, ref, canManage);
                    }
                    return const SizedBox.shrink();
                  }

                  if (items.isEmpty) {
                    return const AppEmptyView(
                      title: 'No Timetable Available',
                      message: 'No periods match the selected filters. Change criteria or create a row entry.',
                    );
                  }

                  final entry = items[index - 2];
                  return _TimetableCard(
                    entry: entry,
                    canManage: canManage,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
        ),
      ],
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
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                if (canManage) ...[
                  Expanded(
                    child: classes.when(
                      data: (items) => DropdownButtonFormField<String?>(
                        initialValue: ref.watch(timetableClassFilterProvider),
                        decoration: const InputDecoration(
                          labelText: 'Filter Class',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
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
                          ref.read(timetableClassFilterProvider.notifier).set(value);
                          ref.read(timetableSectionFilterProvider.notifier).set(null);
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
                            final classId = ref.watch(timetableClassFilterProvider);
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
                              initialValue: ref.watch(timetableSectionFilterProvider),
                              decoration: const InputDecoration(
                                labelText: 'Filter Section',
                                prefixIcon: Icon(Icons.layers_outlined),
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
                                  : (value) => ref.read(timetableSectionFilterProvider.notifier).set(value),
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
                        decoration: const InputDecoration(
                          labelText: 'Filter Teacher',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
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
                        onChanged: (value) => ref.read(timetableTeacherFilterProvider.notifier).set(value),
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
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      entry.subjectName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (canManage)
                  PopupMenuButton<String>(
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
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(entry.dayLabel),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
                Chip(
                  avatar: const Icon(Icons.access_time_outlined, size: 14),
                  label: Text('${entry.startTime} – ${entry.endTime}'),
                  visualDensity: VisualDensity.compact,
                ),
                if (entry.room != null)
                  Chip(
                    avatar: const Icon(Icons.meeting_room_outlined, size: 14),
                    label: Text('Room ${entry.room}'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 6),
                      Text(entry.teacherName, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.school_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('${entry.className} - ${entry.sectionName}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete Period Assignment'),
        content: const Text('Are you sure you want to permanently delete this period? This action cannot be undone.'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Period deleted successfully.')),
          );
        }
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