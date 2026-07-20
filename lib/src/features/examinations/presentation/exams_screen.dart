import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/app_empty_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../students/domain/entities/academic_year.dart';
import '../../students/presentation/providers/student_providers.dart';
import '../domain/entities/exam.dart';
import 'exam_providers.dart';

final class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

final class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  Timer? _debounceTimer;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(examSearchQueryProvider.notifier).set(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examsProvider);
    final academicYearsAsync = ref.watch(academicYearsProvider);
    final selectedYearId = ref.watch(examAcademicYearFilterProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Examinations"),
            Text(
              "Manage exams & schedules",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        onPressed: () => context.push(AppRoute.addExam.path),
        icon: const Icon(Icons.add),
        label: const Text('New Examination'),
      ),
      body: ResponsivePage(
        maxWidth: 950,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.quiz_outlined),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Examination Management",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Create exams, assign subjects, and publish results.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Exam Name',
                        filled: true,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AppAsyncView<List<AcademicYear>>(
                      value: academicYearsAsync,
                      data: (years) {
                        return DropdownButtonFormField<String?>(
                          initialValue: selectedYearId,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            prefixIcon: Icon(Icons.calendar_today),
                            filled: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Academic Years'),
                            ),
                            ...years.map((y) {
                              return DropdownMenuItem(
                                value: y.id,
                                child: Text(y.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            ref.read(examAcademicYearFilterProvider.notifier).set(value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AppAsyncView<List<Exam>>(
                  value: examsAsync,
                  data: (items) {
                    if (items.isEmpty) {
                      return const AppEmptyView(
                        title: 'No Examinations Found',
                        message: 'Create a new exam or change search filters to get started.',
                      );
                    }

                    final publishedCount = items.where((e) => e.status == ExamStatus.published).length;
                    final draftCount = items.where((e) => e.status == ExamStatus.draft).length;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _summaryCard("Total Exams", "${items.length}", Icons.layers_outlined)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: _summaryCard("Published", "$publishedCount", Icons.check_circle_outline, color: Colors.green)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: _summaryCard("Drafts", "$draftCount", Icons.edit_document, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final exam = items[index];
                              final startFormatted = DateFormat('dd MMM yyyy').format(exam.startDate);
                              final endFormatted = exam.endDate != null
                                  ? DateFormat('dd MMM yyyy').format(exam.endDate!)
                                  : 'Ongoing';

                              return Card(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                                          Expanded(
                                            child: Text(
                                              exam.name,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          _buildStatusChip(context, exam.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Chip(
                                            label: Text('Type: ${exam.type.label}'),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          Chip(
                                            avatar: const Icon(Icons.date_range, size: 14),
                                            label: Text('$startFormatted - $endFormatted'),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                      if (exam.description != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          exam.description!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const Divider(height: 24),
                                      Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          FilledButton.tonalIcon(
                                            icon: const Icon(Icons.subject, size: 16),
                                            label: const Text('Manage Subjects'),
                                            onPressed: () => context.push(
                                              '/exams/${exam.id}/subjects',
                                              extra: exam,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (action) => _handleAction(context, ref, action, exam),
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: AppSpacing.sm),
                                                    Text('Edit Details'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'archive',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.archive, size: 20),
                                                    SizedBox(width: AppSpacing.sm),
                                                    Text('Archive'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error),
                                                    const SizedBox(width: AppSpacing.sm),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, {Color? color}) {
    return Builder(
      builder: (context) => Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ExamStatus status) {
    Color containerColor;
    Color textColor;

    switch (status) {
      case ExamStatus.published:
        containerColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade800;
        break;
      case ExamStatus.archived:
        containerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
      case ExamStatus.draft:
        containerColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action, Exam exam) async {
    switch (action) {
      case 'edit':
        await context.push('/exams/${exam.id}/edit');
        break;
      case 'archive':
        final confirm = await _showConfirmDialog(
          context,
          title: 'Archive Examination?',
          content: 'Are you sure you want to archive "${exam.name}"? It will be hidden from active lists.',
          confirmLabel: 'Archive',
        );
        if (confirm == true) {
          unawaited(ref.read(examArchiveProvider)(exam.id));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Examination archived successfully ✅')),
            );
          }
        }
        break;
      case 'delete':
        final confirm = await _showConfirmDialog(
          context,
          title: 'Delete Examination?',
          content: 'Are you sure you want to permanently delete "${exam.name}"? This action cannot be undone.',
          confirmLabel: 'Delete',
          isDanger: true,
        );
        if (confirm == true) {
          unawaited(ref.read(examDeleteProvider)(exam.id));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Examination deleted successfully 🗑️')),
            );
          }
        }
        break;
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: isDanger
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}