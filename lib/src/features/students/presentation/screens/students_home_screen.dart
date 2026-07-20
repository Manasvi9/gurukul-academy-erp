import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/premium_student_widgets.dart';
import 'excel_import_wizard_screen.dart';

class StudentsHomeScreen extends ConsumerWidget {
  const StudentsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userRole = authState.user?.role.value ?? '';
    final permissions = rolePermissions[userRole] ?? {};

    // Using existing provider instead of mock data
    final studentListRequest = const StudentListRequest(
      academicYearId: 'current', // Need to handle dynamic academicYearId
      classId: 'all',
      sectionId: 'all',
    );
    final studentsAsync = ref.watch(studentListProvider(studentListRequest));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          if (permissions.contains(AppPermission.importStudents))
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'import') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExcelImportWizardScreen()),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'import', child: Text('Import Students')),
                const PopupMenuItem(value: 'export', child: Text('Export Students')),
                if (permissions.contains(AppPermission.bulkActions))
                  const PopupMenuItem(value: 'bulk', child: Text('Bulk Actions')),
              ],
            ),
        ],
      ),
      body: AppAsyncView(
        value: studentsAsync,
        data: (students) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SearchBar(hintText: 'Search students...'),
              ),
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No students found'),
                            if (permissions.contains(AppPermission.addStudent)) ...[
                              const SizedBox(height: 16),
                              ActionButton(label: 'Add Student', icon: Icons.add, onPressed: () {}),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return StudentListTile(
                            student: {'name': student.name, 'class': student.className, 'roll': student.rollNumber, 'status': 'Active'},
                            onTap: () => context.pushNamed(AppRoute.studentDetails.name, pathParameters: {'studentId': student.id}),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: permissions.contains(AppPermission.addStudent)
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoute.addStudent.name),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}