import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/app_empty_view.dart';
import 'exam_providers.dart';

final class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = ref.watch(examsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Examinations')),
      body: AppAsyncView(
        value: exams,
        data: (items) => items.isEmpty
            ? const AppEmptyView(
                title: 'No examinations',
                message: 'Create an examination to enter marks.',
              )
            : ListView(
                children: items
                    .map(
                      (exam) => ListTile(
                        title: Text(exam.name),
                        subtitle: Text(
                          '${exam.type} • ${exam.date.toLocal().toString().split(' ')[0]} • ${exam.status}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.archive_outlined),
                          onPressed: () async {
                            await ref
                                .read(examRepositoryProvider)
                                .archive(exam.id);
                            ref.invalidate(examsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exam archived.'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
