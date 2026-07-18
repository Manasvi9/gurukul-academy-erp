import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/student_result.dart';
import 'exam_providers.dart';
import 'result_providers.dart';

class ResultProcessingScreen extends ConsumerWidget {
  const ResultProcessingScreen({required this.exam, super.key});
  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentResultsProvider(exam));
    final isPublished = exam.status == ExamStatus.published;
    final filter = ref.watch(resultFilterProvider);
    final sort = ref.watch(resultSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Result: ${exam.name}'),
        actions: [
          IconButton(
            icon: Icon(isPublished ? Icons.lock : Icons.lock_open),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(isPublished ? 'Unpublish Results' : 'Publish Results'),
                  content: Text(
                    isPublished
                        ? 'Are you sure you want to unpublish these results? This will unlock marks editing.'
                        : 'Are you sure you want to publish these results? This will lock marks editing.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => context.pop(true),
                      child: Text(isPublished ? 'Unpublish' : 'Publish'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                if (isPublished) {
                  await ref.read(examUnpublishProvider)(exam.id);
                } else {
                  await ref.read(examPublishProvider)(exam.id);
                }
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => ref.read(resultFilterProvider.notifier).state = value,
            itemBuilder: (context) => ['All', 'Passed', 'Failed']
                .map((f) => PopupMenuItem(value: f, child: Text(f)))
                .toList(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => ref.read(resultSortProvider.notifier).state = value,
            itemBuilder: (context) => ['Roll Number', 'Name', 'Percentage']
                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                .toList(),
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
              child: AppAsyncView<List<StudentResult>>(
                value: resultsAsync,
                data: (List<StudentResult> results) {
                  final filteredResults = results.where((r) {
                    if (filter == 'Passed') return r.isPass;
                    if (filter == 'Failed') return !r.isPass;
                    return true;
                  }).toList()
                    ..sort((a, b) {
                      if (sort == 'Name') {
                        return a.studentName.compareTo(b.studentName);
                      }
                      if (sort == 'Percentage') {
                        return b.percentage.compareTo(a.percentage);
                      }
                      return a.rollNumber.compareTo(b.rollNumber);
                    });

                  return ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = filteredResults[index];
                      return Card(
                        margin: const EdgeInsets.all(AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(result.studentName),
                          subtitle: Text('Roll: ${result.rollNumber}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${result.percentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                result.isPass ? 'Pass' : 'Fail',
                                style: TextStyle(
                                  color:
                                      result.isPass ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
