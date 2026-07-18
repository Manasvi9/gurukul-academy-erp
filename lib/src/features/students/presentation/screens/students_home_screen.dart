import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/student_providers.dart';
import '../widgets/student_summary_table.dart';

final class StudentsHomeScreen extends ConsumerWidget {
  const StudentsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentStudents = ref.watch(recentlyViewedStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoute.addStudent.path),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add'),
      ),
      body: ResponsivePage(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            FilledButton.icon(
              onPressed: () => context.go(AppRoute.studentSearch.path),
              icon: const Icon(Icons.search),
              label: const Text('Search Student'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _openAcademicYearPicker(context, ref),
              icon: const Icon(Icons.school_outlined),
              label: const Text('Browse By Class'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Recently Viewed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppAsyncView(
              value: recentStudents,
              data: (students) {
                if (students.isEmpty) {
                  return const AppEmptyView(
                    title: 'No recent students',
                    message:
                        'Recently opened student profiles will appear here.',
                  );
                }
                return StudentSummaryTable(
                  students: students,
                  onStudentTap: (student) {
                    context.go('/students/${student.id}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAcademicYearPicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final years = await ref.read(academicYearsProvider.future);
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: years.map((year) {
              return ListTile(
                title: Text(year.name),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/students/classes?academicYearId=${year.id}');
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
