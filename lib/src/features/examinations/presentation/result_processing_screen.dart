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
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Results Dashboard"),
            Text(
              exam.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isPublished ? Icons.lock : Icons.lock_open),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  title: Row(
                    children: [
                      Icon(isPublished ? Icons.lock_open : Icons.lock),
                      const SizedBox(width: 10),
                      Text(
                        isPublished ? 'Unpublish Results' : 'Publish Results',
                      ),
                    ],
                  ),
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
            onSelected: (value) => ref.read(resultFilterProvider.notifier).set(
              ResultFilter.values.firstWhere(
                (e) => e.name.toLowerCase() == value.toLowerCase(),
              ),
            ),
            itemBuilder: (context) => ResultFilter.values
                .map((f) => PopupMenuItem(
                    value: f.name, child: Text(f.name.toUpperCase()),),)
                .toList(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => ref.read(resultSortProvider.notifier).set(
              ResultSort.values.firstWhere(
                (e) => e.name.toLowerCase() == value.toLowerCase(),
              ),
            ),
            itemBuilder: (context) => ResultSort.values
                .map((s) => PopupMenuItem(
                    value: s.name, child: Text(s.name.toUpperCase()),),)
                .toList(),
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
                      "Results Published • Marks Locked",
                      style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
          Expanded(
            child: ResponsivePage(
              maxWidth: 950,
              child: AppAsyncView<List<StudentResult>>(
                value: resultsAsync,
                data: (List<StudentResult> results) {
                  final filteredResults = results.where((r) {
                    if (filter == ResultFilter.passed) return r.isPass;
                    if (filter == ResultFilter.failed) return !r.isPass;
                    return true;
                  }).toList()
                    ..sort((a, b) {
                      if (sort == ResultSort.name) {
                        return a.studentName.compareTo(b.studentName);
                      }
                      if (sort == ResultSort.percentage) {
                        return b.percentage.compareTo(a.percentage);
                      }
                      return a.rollNumber.compareTo(b.rollNumber);
                    });

                  if (filteredResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assessment_outlined,
                            size: 72,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Results Available",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Process marks before publishing results.",
                          ),
                        ],
                      ),
                    );
                  }

                  final passCount =
                      filteredResults.where((e) => e.isPass).length;
                  final highest = filteredResults.isEmpty
                      ? 0.0
                      : filteredResults
                          .map((e) => e.percentage)
                          .reduce((a, b) => a > b ? a : b);

                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                context,
                                "Students",
                                "${filteredResults.length}",
                                Icons.groups_outlined,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _summaryCard(
                                context,
                                "Passed",
                                "$passCount",
                                Icons.check_circle_outline,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _summaryCard(
                                context,
                                "Highest",
                                "${highest.toStringAsFixed(1)}%",
                                Icons.emoji_events_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: ListView.separated(
                            itemCount: filteredResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final result = filteredResults[index];
                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    context.pushNamed(
                                      "reportCard",
                                      extra: {
                                        "exam": exam,
                                        "student": result,
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          child: Text(result.rollNumber.toString()),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result.studentName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              Text(
                                                "Roll No. ${result.rollNumber}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${result.percentage.toStringAsFixed(1)}%",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Chip(
                                              avatar: Icon(
                                                result.isPass
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: 16,
                                              ),
                                              label: Text(
                                                result.isPass ? "PASS" : "FAIL",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}