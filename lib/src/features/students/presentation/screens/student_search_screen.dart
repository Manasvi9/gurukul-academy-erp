import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/student_providers.dart';
import '../widgets/student_summary_table.dart';

final class StudentSearchScreen extends ConsumerWidget {
  const StudentSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(studentSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Student')),
      body: ResponsivePage(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Name, SR number, parent name or mobile',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref
                    .read(studentSearchControllerProvider.notifier)
                    .search(value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAsyncView(
              value: searchResults,
              data: (students) {
                if (students.isEmpty) {
                  return const AppEmptyView(
                    title: 'No students found',
                    message: 'Search by student, SR number, parent, or mobile.',
                  );
                }
                return StudentSummaryTable(
                  students: students,
                  onStudentTap: (student) =>
                      context.go('/students/${student.id}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
