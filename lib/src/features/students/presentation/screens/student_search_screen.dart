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
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search Students'),
            Text(
              'Find students quickly',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/students/add'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
      body: ResponsivePage(
        maxWidth: 1100,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by name, SR number, parent or mobile',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.manage_search_outlined),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
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
                    title: 'No Students Found',
                    message:
                        'Search using student name, SR number, parent name or mobile number.',
                  );
                }

                return Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: StudentSummaryTable(
                    students: students,
                    onStudentTap: (student) =>
                        context.go('/students/${student.id}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}