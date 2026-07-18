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

final class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsProvider);
    final academicYearsAsync = ref.watch(academicYearsProvider);
    final selectedYearId = ref.watch(examAcademicYearFilterProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Examinations'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFECE0), // Soft peach bg
        foregroundColor: const Color(0xFF8B4F30), // Dark peach/brown text
        onPressed: () => context.push(AppRoute.addExam.path),
        icon: const Icon(Icons.add),
        label: const Text('Create Exam', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome / Statistics Card with soft peach accent
              Card(
                color: const Color(0xFFFFECE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFFCCAC)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.school, size: 40, color: Color(0xFF8B4F30)),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Examination Management',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4F30),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Setup examinations, define schedules, and manage draft or published statuses.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E6549),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Exam Name',
                        fillColor: Color(0xFFF9F9F9),
                        filled: true,
                      ),
                      onChanged: (value) =>
                          ref.read(examSearchQueryProvider.notifier).state = value,
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
                            fillColor: Color(0xFFF9F9F9),
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
                            ref.read(examAcademicYearFilterProvider.notifier).state =
                                value;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Examination List
              Expanded(
                child: AppAsyncView<List<Exam>>(
                  value: examsAsync,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No Examinations Found',
                          message: 'Create a new exam or change search filters to get started.',
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final exam = items[index];
                            final startFormatted = DateFormat('dd MMM yyyy').format(exam.startDate);
                            final endFormatted = exam.endDate != null
                                ? DateFormat('dd MMM yyyy').format(exam.endDate!)
                                : 'Ongoing';

                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exam.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    _buildStatusChip(exam.status),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      'Type: ${exam.type.label}',
                                      style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Schedule: $startFormatted - $endFormatted',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                    if (exam.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        exam.description!,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) => _handleAction(context, ref, action, exam),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: AppSpacing.sm),
                                          Text('Edit'),
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
                                          Icon(Icons.delete, size: 20, color: Colors.red.shade600),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text('Delete', style: TextStyle(color: Colors.red.shade600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildStatusChip(ExamStatus status) {
    Color bg;
    Color text;
    switch (status) {
      case ExamStatus.published:
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        break;
      case ExamStatus.archived:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        break;
      case ExamStatus.draft:
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
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
              const SnackBar(content: Text('Examination archived successfully')),
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
              const SnackBar(content: Text('Examination deleted successfully')),
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
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: isDanger
                ? FilledButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white)
                : FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFECE0),
                    foregroundColor: const Color(0xFF8B4F30),
                  ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
