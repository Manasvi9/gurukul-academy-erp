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
      appBar: AppBar(title: const Text('Student List')),
      body: ResponsivePage(
        maxWidth: 900,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppAsyncView(
            value: students,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No students',
                  message: 'No active students were found in this section.',
                );
              }
              return StudentSummaryTable(
                students: items,
                onStudentTap: (student) => context.go('/students/${student.id}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
