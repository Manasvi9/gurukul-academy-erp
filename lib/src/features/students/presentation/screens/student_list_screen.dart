import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/student_providers.dart';
import '../widgets/student_summary_table.dart';

final class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    super.key,
  });

  final String academicYearId;
  final String classId;
  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(
      studentListProvider(
        StudentListRequest(
          academicYearId: academicYearId,
          classId: classId,
          sectionId: sectionId,
        ),
      ),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () => context.go('/students/add'),
  icon: const Icon(Icons.person_add_alt_1),
  label: const Text('Add Student'),
),
      appBar: AppBar(
  elevation: 0,
  centerTitle: false,
  titleSpacing: 20,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Students'),
      Text(
        'Student List',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  ),
),
      body: ResponsivePage(
        maxWidth: 1100,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppAsyncView(
            value: students,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No Students Found',
                  message: 'There are no active students in this class and section yet.',
                );
              }
              return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        '${items.length} Students',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ),
    Expanded(
      child: Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  clipBehavior: Clip.antiAlias,
  child: StudentSummaryTable(
    students: items,
    onStudentTap: (student) =>
        context.go('/students/${student.id}'),
  ),
),
),
],
);
            },
          ),
        ),
      ),
    );
  }
}
